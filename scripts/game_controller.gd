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
@brief Maximum number of agents that can be assigned
"""
@onready var max_agents: int = Constants.INIT_MAX_AGENTS

"""
@brief Current turn number
"""
var turn_number: int = 0

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree
"""
func _ready() -> void:
	calendar = Calendar.new()
	EventBus.selected_radial_option.connect(_on_radial_option_selected)

#|==============================|
#|      Getters & Setters      |
#|==============================|

"""
@breif Sets the town name

@param name The name of the town
"""
func set_town_name(name: String) -> void:
	town_name = name

"""
@brief Gets the town name
@returns The name of the town
"""
func get_town_name() -> String:
	return town_name

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
	print("Adding action: ", action_type, " to POI: ", poi.poi_name)
	var actions = GlobalRegistry.actions.get_all_items()

	print("Actions: ", actions.size())

	for character in characters:
		print("Action character: ", character.get_full_name())
	# check if this character is already assigned to an action
	for action in actions:
		print("Action: ", action.action_type)
		for character in action.characters:
			print("Test Action character: ", character.get_full_name())
		# check if any of the characters are already assigned to this action
		if action.characters.any(func(c): return characters.has(c)) and action.in_flight == false:
			print("Deleting previous action that character is already assigned to")
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

	# Emit the signal to begin processing the turn
	EventBus.turn_processing_initiated.emit(turn_number)
	
	# ...actions will receive the signal and process themselves, adding logs, changing statuses, etc.

	WorldEventFactory.randomise_world_event_from_heat(get_heat_level())

	# Decrease the heat for each district
	for district in GlobalRegistry.districts.get_all_items():
		var reduction: int = MathHelpers.generateBellCurveStat(Constants.DISTRICT_HEAT_DECREASE_PER_TURN_MIN, Constants.DISTRICT_HEAT_DECREASE_PER_TURN_MAX)
		district.heat -= reduction

		if (reduction > 0):
			var turn_log = TurnLog.new(district.district_name + " heat decreased by " + str(reduction), Enums.LogType.WORLD_INFO)
			GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), turn_log)

	# Check for endgame conditions
	# TODO: Maybe there should be a property on GameController that tracks if we're in an endgame state and locks out other actions etc.
	if get_heat_level() > 80:
		_trigger_heat_endgame()
	elif get_resistance_level() > 80:
		_trigger_resistance_endgame()

	# Emit the signal to end the turn
	EventBus.end_turn_complete.emit(turn_number)


"""
@brief Triggers the heat endgame
"""
func _trigger_heat_endgame() -> void:
	# TODO: Create a custom endgame WorldEvent
	# TODO: Create custom endgame Plan(s)
	pass

"""
@brief Triggers the resistance endgame
"""
func _trigger_resistance_endgame() -> void:
	# TODO: Create a custom endgame WorldEvent
	# TODO: Create custom endgame Plan(s)
	pass

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
	print("Opening radial menu for POI: ", poi)
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
		print("Showing info for POI: ", poi_for_radial)
		# poi_for_radial.show_info()
		# create a tiny timer to get around erroneous clickthroughs
		await get_tree().create_timer(0.1).timeout
		radial_menu_open = null
		return

	# popup a post_radial_assignment menu
	var post_radial_assignment = Globals.post_radial_assignment_scene.instantiate()
	post_radial_assignment.set_option(option)
	post_radial_assignment.connect('post_radial_assignment_option', _on_post_radial_assignment_option_selected)
	EventBus.open_new_window.emit(post_radial_assignment)

func _on_post_radial_assignment_option_selected(option: Enums.ActionType, selected_agents: Array[Character], additions: Array) -> void:
	if option != Enums.ActionType.NONE and option != Enums.ActionType.INFO:
		GameController.add_action(poi_for_radial, selected_agents, option)

	# create a tiny timer to get around erroneous clickthroughs
	await get_tree().create_timer(0.1).timeout
	EventBus.close_all_windows.emit()
	radial_menu_open = null
