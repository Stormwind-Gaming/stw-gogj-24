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
@brief List of actions for the current turn
"""
var actions: Array[Action] = []

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
@brief Emitted when a turn ends
"""
signal end_turn_initiated(num: int)

"""
@brief Emitted when turn processing is complete
"""
signal end_turn_complete(num: int)

"""
@brief Emitted when a district becomes focused
"""
signal district_just_focused(district: District)

"""
@brief Emitted when a new district is registered
"""
signal new_district_registered(district: District)

"""
@brief Emitted when an agent's status changes
"""
signal agent_changed(agent: Character)

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
	var characters = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	for character in characters.values():
		# TODO: Check this works
		# level += character.char_sympathy
		break

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
	# check if this character is already assigned to an action
	for action in actions:
		for existing_action_character in action.characters:
			for new_action_character in characters:
				if existing_action_character == new_action_character:
					# delete the previous action
					remove_action(action)

	# print("Adding action:", poi, characters, action_type)
	var new_action = Action.new(poi, characters, action_type, additional_info)
	actions.append(new_action)

"""
@brief Removes an action from the current turn

@param action The action to remove
"""
func remove_action(action: Action) -> void:
	actions.erase(action)

func remove_all_actions_for_character(character: Character) -> void:
	for action in actions:
		if character in action.characters:
			remove_action(action)

func remove_agent(character: Character) -> void:
	character.unset_agent()

#|==============================|
#|      Turn Processing        |
#|==============================|
"""
@brief Processes the current turn and advances game state
"""
func process_turn() -> void:
	end_turn_initiated.emit(turn_number)  # Emit the end turn signal

	turn_number += 1  # Increment the turn number
	calendar.increment_day()  # Increment the day

	for action in actions:

		match action.action_type:
			Enums.ActionType.ESPIONAGE:
				_espionage_action(action)

			Enums.ActionType.SURVEILLANCE:
				_surveillance_action(action)

			Enums.ActionType.PROPAGANDA:
				_propaganda_action(action)
				
			Enums.ActionType.PLAN:
				_plan_action(action)
				
		# set all agents back to available
		for agent in action.characters:
			#TODO: do an assigned check here to futureproof agents getting set to other statuses during the action (e.g. captured / dead)

			if agent.char_status == Enums.CharacterStatus.ASSIGNED:
				agent.char_status = Enums.CharacterStatus.DEFAULT

	# Store the logs for this turn
	turn_logs.append(current_turn_log)
	# Clear the actions list for the next turn
	actions.clear()

	# Clear the current turn log
	current_turn_log = []

	# Emit the signal to end the turn
	end_turn_complete.emit(turn_number)

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
		# set all agents to assigned
		for agent in selected_agents:
			agent.current_status = Enums.CharacterStatus.ASSIGNED
		new_assignment.emit(option, poi_for_radial, selected_agents)

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

#|==============================|
#|      Action Processing      |
#|==============================|
"""
@brief Processes an espionage action

@param action The action to process
"""
func _espionage_action(action:Action) -> void:
	var log_message = "Processing ESPIONAGE action at [u]" + str(action.poi.poi_name) + "[/u] by "

	var success = false

	for character in action.characters:
		log_message += "[u]" + character.first_name + " " + character.last_name + "[/u], "

	current_turn_log.append(log_message)

	var combined_subtlety = 0
	var combined_smarts = 0
	var combined_charm = 0

	for character in action.characters:
		combined_subtlety += character.subtlety
		combined_smarts += character.smarts
		combined_charm += character.charm
	
	var subtle_roll = MathHelpers.bounded_sigmoid_check(combined_subtlety, true)
	
	if(subtle_roll.success):
		log_message = "Succeeded subtlety check..."
		# log_message += str(subtle_roll)
		current_turn_log.append(log_message)

	else:
		log_message = "Failed subtlety check... heat increased"
		# log_message += str(subtle_roll)
		action.poi.parent_district.heat += 5
		current_turn_log.append(log_message)
		
	match action.poi.stat_check_type:
		Enums.StatCheckType.SMARTS:
			
			var smarts_roll = MathHelpers.bounded_sigmoid_check(combined_smarts, true)
			
			if(smarts_roll.success):
				log_message = "Succeeded smarts check..."
			# log_message += str(smarts_roll)
				current_turn_log.append(log_message)
				success = true
			else: 
				log_message = "Failed smarts check..."
			# log_message += str(smarts_roll)
				current_turn_log.append(log_message)

		Enums.StatCheckType.CHARM:
			if(MathHelpers.bounded_sigmoid_check(combined_charm)):
				log_message = "Succeeded charm check..."
				current_turn_log.append(log_message)
				success = true
			else: 
				log_message = "Failed charm check..."
				current_turn_log.append(log_message)

	if success:
		log_message = "[color=green]The mission was a success![/color]"
		current_turn_log.append(log_message)
		IntelFactory.create_rumour(action.poi.rumour_config)
	else:
		log_message = "[color=red]The mission was a failure! :([/color]"
		current_turn_log.append(log_message)

	current_turn_log.append("\n")

func _surveillance_action(action:Action) -> void:

	var log_message = "Processing SURVEILLANCE action at [u]" + str(action.poi.poi_name) + "[/u] by "

	var success = false

	for character in action.characters:
		log_message += "[u]" + character.first_name + " " + character.last_name + "[/u], "

	current_turn_log.append(log_message)

	var combined_subtlety = 0
	var combined_smarts = 0
	var combined_charm = 0

	for character in action.characters:
		combined_subtlety += character.subtlety
		combined_smarts += character.smarts
		combined_charm += character.charm
	
	var subtle_roll = MathHelpers.bounded_sigmoid_check(combined_subtlety, true)
	
	if(subtle_roll.success):
		log_message = "Succeeded subtlety check..."
		# log_message += str(subtle_roll)
		current_turn_log.append(log_message)

	else:
		log_message = "Failed subtlety check... heat increased"
		# log_message += str(subtle_roll)
		action.poi.parent_district.heat += 5
		current_turn_log.append(log_message)

	
	var smarts_roll = MathHelpers.bounded_sigmoid_check(combined_smarts, true)
	
	if(smarts_roll.success):
		log_message = "Succeeded smarts check..."
	# log_message += str(smarts_roll)
		current_turn_log.append(log_message)
		success = true
	else: 
		log_message = "Failed smarts check..."
	# log_message += str(smarts_roll)
		current_turn_log.append(log_message)

	if success:
		log_message = "[color=green]The mission was a success![/color]"
		current_turn_log.append(log_message)
		action.poi.poi_owner.known = true
		log_message = "[color=green]" + action.poi.poi_owner.get_full_name() + " is now known to us[/color]"
		current_turn_log.append(log_message)
	else:
		log_message = "[color=red]The mission was a failure! :([/color]"
		current_turn_log.append(log_message)

	current_turn_log.append("\n")

func _propaganda_action(action:Action) -> void:
	var log_message = "Processing PROPAGANDA action at [u]" + str(action.poi.poi_name) + "[/u] by "

	var success = false

	for character in action.characters:
		log_message += "[u]" + character.first_name + " " + character.last_name + "[/u], "

	current_turn_log.append(log_message)

	var combined_subtlety = 0
	var combined_smarts = 0
	var combined_charm = 0

	for character in action.characters:
		combined_subtlety += character.subtlety
		combined_smarts += character.smarts
		combined_charm += character.charm
	
	var subtle_roll = MathHelpers.bounded_sigmoid_check(combined_subtlety, true)
	
	if(subtle_roll.success):
		log_message = "Succeeded subtlety check..."
		# log_message += str(subtle_roll)
		current_turn_log.append(log_message)

	else:
		log_message = "Failed subtlety check... heat increased"
		# log_message += str(subtle_roll)
		action.poi.parent_district.heat += 5
		current_turn_log.append(log_message)

	if(MathHelpers.bounded_sigmoid_check(combined_charm)):
		log_message = "Succeeded charm check..."
		current_turn_log.append(log_message)
		success = true
	else: 
		log_message = "Failed charm check..."
		current_turn_log.append(log_message)

	if success:
		log_message = "[color=green]The mission was a success![/color]"
		current_turn_log.append(log_message)
		action.poi.poi_owner.set_sympathy(action.poi.poi_owner.sympathy + 5)
		log_message = "[color=green]" + action.poi.poi_owner.get_full_name() + " is now more sympathetic to our cause![/color]"
		current_turn_log.append(log_message)
	else:
		log_message = "[color=red]The mission was a failure! :([/color]"
		current_turn_log.append(log_message)

	current_turn_log.append("\n")

func _plan_action(action:Action) -> void:

	var log_message = "Processing PLAN action at [u]" + str(action.poi.poi_name) + "[/u] by "

	var success = false

	for character in action.characters:
		log_message += "[u]" + character.first_name + " " + character.last_name + "[/u], "

	current_turn_log.append(log_message)

	var combined_subtlety = 0
	var combined_smarts = 0
	var combined_charm = 0

	for character in action.characters:
		combined_subtlety += character.subtlety
		combined_smarts += character.smarts
		combined_charm += character.charm

	log_message = "oh god... how is this bit supposed to work?! "

	current_turn_log.append(log_message)
