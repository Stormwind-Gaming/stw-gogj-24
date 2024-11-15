extends Node

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Currently focused district
"""
var district_focused: District = null

"""
@brief List of currently open menu IDs
"""
var menus_open: Array[String] = []

"""
@brief POI associated with current radial menu
"""
var poi_for_radial: PointOfInterest

"""
@brief Currently open radial menu instance
"""
var radial_menu_open: RadialMenu

"""
@brief List of all districts in the game
"""
var districts: Array[District] = []

"""
@brief Calendar instance for tracking game time
"""
var calendar: Calendar

"""
@brief Maximum number of agents that can be assigned
"""
var max_agents: int = 2

"""
@brief Current turn number
"""
var turn_number: int = 0

"""
@brief Log of all turn outcomes
"""
var turn_logs: Array = []

"""
@brief Log entries for current turn
"""
var current_turn_log: Array = []

#|==============================|
#|          Signals            |
#|==============================|
"""
@brief Emitted when a district becomes focused
"""
signal district_just_focused(district: District)

"""
@brief Emitted when a new district is registered
"""
signal new_district_registered(district: District)

"""
@brief Emitted when a new action is assigned
"""
signal new_assignment(option: Enums.ActionType, poi: PointOfInterest, agents: Array[Character])

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree
"""
func _ready() -> void:
	calendar = Calendar.new()

#|==============================|
#|      Getters & Setters      |
#|==============================|
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
	# TODO: Implement this

	return 0

func get_turn_log(num: int) -> Array:
	if turn_logs.size() < 1:
		return []
	return turn_logs[num]


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
	EventBus.end_turn_initiated.emit(turn_number)  # Emit the end turn signal

	turn_number += 1  # Increment the turn number
	calendar.increment_day()  # Increment the day

	# Create the turn log list for this turn
	GlobalRegistry.turn_logs.create_list(str(turn_number))

	# Emit the signal to begin processing the turn
	EventBus.turn_processing_initiated.emit(turn_number) 
	
	# ...actions will receive the signal and process themselves, adding logs, changing statuses, etc.

	# Emit the signal to end the turn
	EventBus.end_turn_complete.emit(turn_number)

#|==============================|
#|      District Management    |
#|==============================|
"""
@brief Registers a new district in the game

@param district The district to register
"""
func register_district(district: District) -> void:
	districts.append(district)
	emit_signal("new_district_registered", district)

"""
@brief Sets the currently focused district

@param district The district to set as focused
"""
func set_district_focused(district: District) -> void:
	district_focused = district
	emit_signal("district_just_focused", district)

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
		return
	radial_menu_open = radial_menu
	poi_for_radial = poi
	radial_menu.connect('selected_radial_option', _on_radial_option_selected)

func _on_radial_option_selected(option: Enums.ActionType) -> void:
	radial_menu_open.hide()

	# if quit, do nothing
	if option == Enums.ActionType.NONE:
		# create a tiny timer to get around erroneous clickthroughs
		await get_tree().create_timer(0.1).timeout
		radial_menu_open.queue_free()
		radial_menu_open = null
		return
	
	# if info, show info
	if option == Enums.ActionType.INFO:
		print("Showing info for POI: ", poi_for_radial)
		# poi_for_radial.show_info()
		# create a tiny timer to get around erroneous clickthroughs
		await get_tree().create_timer(0.1).timeout
		radial_menu_open.queue_free()
		radial_menu_open = null
		return

	# popup a post_radial_assignment menu
	var post_radial_assignment = Globals.post_radial_assignment_scene.instantiate()
	post_radial_assignment.set_option(option)
	post_radial_assignment.connect('post_radial_assignment_option', _on_post_radial_assignment_option_selected)
	add_child(post_radial_assignment)

func _on_post_radial_assignment_option_selected(option: Enums.ActionType, selected_agents: Array[Character], additions: Array) -> void:
	if option != Enums.ActionType.NONE and option != Enums.ActionType.INFO:
		GameController.add_action(poi_for_radial, selected_agents, option)

	# create a tiny timer to get around erroneous clickthroughs
	await get_tree().create_timer(0.1).timeout
	radial_menu_open.queue_free()
	radial_menu_open = null

"""
@brief Sets the menu open state

@param id The ID of the menu to set as open
"""
func set_menu_open(id: String) -> void:
	menus_open.append(id)
	emit_signal("menu_opened", id)

"""
@brief Sets the menu closed state

@param id The ID of the menu to set as closed
"""
func set_menu_closed(id: String) -> void:
	menus_open.erase(id)
