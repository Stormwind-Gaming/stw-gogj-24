extends Node

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Name of the town this map represents
"""
var town_name: String = ""

"""
@brief Currently focused district
"""
var district_focused: District = null

"""
@brief POI associated with current radial menu
"""
var poi_for_radial: PointOfInterest

"""
@brief Currently open radial menu instance
"""
var radial_menu_open: RadialMenu

"""
@brief Calendar instance for tracking game time
"""
var calendar: Calendar

"""
@brief TownDetails instance for managing town details
"""
var town_details: TownDetails

"""
@brief Maximum number of agents that can be assigned
"""
@onready var max_agents: int = Constants.INIT_MAX_AGENTS

"""
@brief Current turn number
"""
var turn_number: int = 0

"""
@brief Whether an endgame has been triggered
"""
var endgame_triggered: bool = false

var heat_endgame_port_step: int = 0
var heat_endgame_train_step: int = 0
var resistance_endgame_step: int = 0

#|==============================|
#|      Lifecycle Methods      |
#|==============================|

"""
@brief Called when the node enters the scene tree
"""
func _ready() -> void:
	calendar = Calendar.new()
	town_details = TownDetails.new()
	EventBus.selected_radial_option.connect(_on_radial_option_selected)

"""
@brief Resets the GameController
"""
func reset() -> void:
	turn_number = 0
	endgame_triggered = false
	heat_endgame_port_step = 0
	heat_endgame_train_step = 0
	resistance_endgame_step = 0
	max_agents = Constants.INIT_MAX_AGENTS


#|==============================|
#|      Getters & Setters      |
#|==============================|

"""
@brief Gets the town name
@returns The name of the town
"""
func get_town_name() -> String:
	return town_details.town_name

"""
@brief Gets the current resistance level
@returns The current resistance level
"""
func get_resistance_level() -> int:
	var level = 0
	var characters = GlobalRegistry.characters.get_all_items()
	for character in characters:
		if character.char_sympathy:
			level += character.char_sympathy

	if characters.size() == 0:
		return 0
	
	return level / characters.size()

"""
@brief Gets the current heat level
@returns The current heat level
"""
func get_heat_level() -> int:
	var level = 0
	var districts = GlobalRegistry.districts.get_all_items()
	for district in districts:
		level += district.heat

	if districts.size() == 0:
		return 0

	return level / districts.size()


#|==============================|
#|      Action Management      |
#|==============================|
"""
@brief Adds a new action to the current turn

@param poi The POI where the action takes place
@param characters The agents performing the action
@param action_type The type of action being performed
@param additional_info Optional additional data for the action
"""
func add_action(poi: PointOfInterest, characters: Array[Character], action_type: Enums.ActionType, additional_info: Dictionary = {}) -> void:
	var actions = GlobalRegistry.actions.get_all_items()

	# check if this character is already assigned to an action
	for action in actions:
		# check if any of the characters are already assigned to this action
		if action.characters.any(func(c): return characters.has(c)) and action.in_flight == false:
			action.queue_free()
		# for existing_action_character in action.characters:
		# 	for new_action_character in characters:
		# 		if existing_action_character == new_action_character:
		# 			# delete the previous action
		# 			action.queue_free()

	var action_config = ActionFactory.ActionConfig.new()
	action_config.poi = poi
	action_config.characters = characters
	action_config.action_type = action_type
	action_config.additional_info = additional_info


	#TODO: Not sure if this is the best way to handle this
	if action_type == Enums.ActionType.PLAN:
		# Find the plan associated with this POI
		var plan = GlobalRegistry.intel.find_item(GlobalRegistry.LIST_PLANS, "plan_subject_poi", poi)
		action_config.additional_info["associated_plan"] = plan

	ActionFactory.create_action(action_config)


func remove_all_actions_for_character(character: Character) -> void:
	var actions = GlobalRegistry.actions.get_all_items()
	for action in actions:
		if character in action.characters:
				# delete the previous action
				action.queue_free()
	

#|==============================|
#|      Turn Processing        |
#|==============================|
"""
@brief Processes the current turn and advances game state
"""
func process_turn() -> void:
	EventBus.end_turn_initiated.emit(turn_number) # Emit the end turn signal

	turn_number += 1 # Increment the turn number
	calendar.increment_day() # Increment the day

	# Create the turn log list for this turn
	GlobalRegistry.turn_logs.create_list(str(turn_number))

	# Return injured characters to the pool
	var injured_characters = GlobalRegistry.characters.find_items_across_lists("char_state", Enums.CharacterState.INJURED)
	for character in injured_characters:
		if not character.injured_return_on_turn or character.injured_return_on_turn <= turn_number:
			character.char_state = Enums.CharacterState.AVAILABLE
			var turn_log = TurnLog.new(character.get_full_name() + " has returned from injury", Enums.LogType.WORLD_INFO)
			GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), turn_log)
			character.injured_return_on_turn = null

	# Districts with actions
	var districts_with_actions = []
	for action in GlobalRegistry.actions.get_all_items():
		districts_with_actions.append(action.poi.parent_district)

	# Emit the signal to begin processing the turn
	EventBus.turn_processing_initiated.emit(turn_number)
	
	# ...actions will receive the signal and process themselves, adding logs, changing statuses, etc.

	WorldEventFactory.randomise_world_event_from_heat(get_heat_level())

	# Decrease the heat for each district where there are no actions
	for district in GlobalRegistry.districts.get_all_items():
		if not districts_with_actions.has(district):
			var reduction: int = MathHelpers.generate_bell_curve_stat(Constants.DISTRICT_HEAT_DECREASE_PER_TURN_MIN, Constants.DISTRICT_HEAT_DECREASE_PER_TURN_MAX)
			district.heat -= reduction

			if (reduction > 0):
				var turn_log = TurnLog.new(district.district_name + " heat decreased by " + str(reduction), Enums.LogType.WORLD_INFO)
				GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), turn_log)

	# Check for endgame conditions
	if not endgame_triggered:
		if get_heat_level() > Constants.HEAT_ENDGAME_THRESHOLD:
			_trigger_heat_endgame()
		elif get_resistance_level() > Constants.RESISTANCE_ENDGAME_THRESHOLD:
			_trigger_resistance_endgame()

	# check if player has any sympathisers left
	var all_sympathisers = GlobalRegistry.characters.list_size(GlobalRegistry.LIST_SYMPATHISER_RECRUITED) + GlobalRegistry.characters.list_size(GlobalRegistry.LIST_SYMPATHISER_NOT_RECRUITED)
	if all_sympathisers == 0:
		EventBus.game_over.emit()
	else:
		# Emit the signal to end the turn
		EventBus.end_turn_complete.emit(turn_number)


"""
@brief Triggers the heat endgame
"""
func _trigger_heat_endgame() -> void:
	print("Triggering heat endgame")
	endgame_triggered = true
	EventBus.endgame_triggered.emit()

	WorldEventFactory.create_world_event(Enums.WorldEventSeverity.ENDGAME)
	IntelFactory.create_heat_endgame_plan()

	var turn_log = TurnLog.new("Heat endgame triggered - Check Intel for Plans", Enums.LogType.WORLD_EVENT)
	GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), turn_log)

	EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.HEAT_ENDGAME, [] as Array[Character], null)

	# Clear current intel and actions
	GlobalRegistry.intel.clear_list(GlobalRegistry.LIST_PLANS)
	GlobalRegistry.intel.clear_list(GlobalRegistry.LIST_RUMOURS)
	GlobalRegistry.actions.clear_list(GlobalRegistry.LIST_ALL_ACTIONS)

	var docks_plan_properties = Plan.PlanProperties.new()
	var docks_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.DOCKS)
	docks_plan_properties.plan_name = "Head for the port."
	docks_plan_properties.plan_text = "Gather what you can and head for the port immediately, you’ll need to cross into the port district first. Avoid detection at the checkpoint."
	docks_plan_properties.plan_expiry = -1
	docks_plan_properties.plan_subject_poi = docks_poi
	docks_plan_properties.is_endgame_plan = true
	Plan.new(docks_plan_properties)


	var train_plan_properties = Plan.PlanProperties.new()
	var train_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.TRAIN_STATION)
	train_plan_properties.plan_name = "Head for the station."
	train_plan_properties.plan_text = "Gather what you can and head for the train station immediately, you’ll need to cross into the industry district first. Avoid detection at the checkpoint, there is a spare military uniform available, you can use that as a disguise!"
	train_plan_properties.plan_expiry = -1
	train_plan_properties.plan_subject_poi = train_poi
	train_plan_properties.is_endgame_plan = true
	Plan.new(train_plan_properties)


	print("Heat endgame plan created")

"""
@brief Triggers the resistance endgame
"""
func _trigger_resistance_endgame() -> void:
	print("Triggering resistance endgame")
	endgame_triggered = true
	EventBus.endgame_triggered.emit()

	## TODO: this is causing a type error - Enums.WorldEventType doesnt exist
	# WorldEventFactory.create_world_event(Enums.WorldEventType.ENDGAME)
	IntelFactory.create_resistance_endgame_plan()

	var turn_log = TurnLog.new("Resistance endgame triggered - Check Intel for Plans", Enums.LogType.WORLD_EVENT)
	GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), turn_log)

	EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.RESISTANCE_ENDGAME, [] as Array[Character], null)

	# Clear current intel and actions
	GlobalRegistry.intel.clear_list(GlobalRegistry.LIST_PLANS)
	GlobalRegistry.intel.clear_list(GlobalRegistry.LIST_RUMOURS)
	GlobalRegistry.actions.clear_list(GlobalRegistry.LIST_ALL_ACTIONS)

	var airbase_plan_properties = Plan.PlanProperties.new()
	var airbase_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.AIR_BASE)
	airbase_plan_properties.plan_name = "Assemble the team."
	airbase_plan_properties.plan_text = "Assemble the team,  collect the explosives and move to the military district. We acquired some uniforms previously, so we can go in disguise as an infantry patrol. We even have an old truck that can pass for a squad vehicle."
	airbase_plan_properties.plan_expiry = -1
	airbase_plan_properties.plan_subject_poi = airbase_poi
	airbase_plan_properties.is_endgame_plan = true
	Plan.new(airbase_plan_properties)


#|==============================|
#|      District Management    |
#|==============================|

"""
@brief Sets the currently focused district

@param district The district to set as focused
"""
func set_district_focused(district: District) -> void:
	district_focused = district
	EventBus.district_just_focused.emit(district)
	if district == null:
		_on_radial_option_selected(Enums.ActionType.NONE)


#|==============================|
#|      Menu Management        |
#|==============================|
"""
@brief Opens a radial menu for a POI

@param radial_menu The menu instance to open
@param poi The POI the menu is for
"""
func open_radial_menu(radial_menu: RadialMenu, poi: PointOfInterest) -> void:
	if radial_menu_open:
		print("Radial menu already open, closing")
		return
	radial_menu_open = radial_menu
	poi_for_radial = poi

"""
@brief Handles radial option selection

@param option The option selected
"""
func _on_radial_option_selected(option: Enums.ActionType) -> void:
	if not radial_menu_open:
		return

	radial_menu_open.hide()

	# if quit, do nothing
	if option == Enums.ActionType.NONE:
		# create a tiny timer to get around erroneous clickthroughs
		await get_tree().create_timer(0.1).timeout
		radial_menu_open = null
		return
	
	# if info, show info
	if option == Enums.ActionType.INFO:
		var town_details_list_instance = Globals.town_details_list_scene.instantiate()
		EventBus.open_new_window.emit(town_details_list_instance)
		
		EventBus.open_poi_information.emit(poi_for_radial)

		# create a tiny timer to get around erroneous clickthroughs
		await get_tree().create_timer(0.1).timeout
		radial_menu_open = null
		return

	# popup a post_radial_assignment menu
	var post_radial_assignment = Globals.post_radial_assignment_scene.instantiate()
	post_radial_assignment.set_option(option)
	post_radial_assignment.connect('post_radial_assignment_option', _on_post_radial_assignment_option_selected)
	EventBus.open_new_window.emit(post_radial_assignment)

func _on_post_radial_assignment_option_selected(option: Enums.ActionType, selected_agents: Array[Character], _additions: Array) -> void:
	if option != Enums.ActionType.NONE and option != Enums.ActionType.INFO:
		GameController.add_action(poi_for_radial, selected_agents, option)

	# create a tiny timer to get around erroneous clickthroughs
	await get_tree().create_timer(0.1).timeout
	EventBus.close_window.emit()
	EventBus.close_radial_menu.emit()
	radial_menu_open = null
