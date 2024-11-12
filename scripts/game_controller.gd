extends Node

var district_focused: District = null
var menus_open: Array[String] = []

var poi_for_radial: PointOfInterest
var radial_menu_open: RadialMenu
var districts: Array[District] = []
var calendar: Calendar

var max_agents: int = 2

signal end_turn_initiated(num: int)
signal end_turn_complete(num: int)
signal district_just_focused(district: District)
signal new_district_registered(district: District)
signal agent_changed(agent: Character)
signal new_assignment(option: Enums.ActionType, poi: PointOfInterest, agents: Array[Character])

func _ready() -> void:
	calendar = Calendar.new()

# List to store all actions for the current turn
var actions: Array[Action] = []
# Variable to track the current turn number
var turn_number: int = 0
# Multidimensional array to log the output of each turn
var turn_logs: Array = []
# Store current turn log
var current_turn_log: Array = []

# Method to add an action
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


# Method to process a turn
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
			# do an assigned check here to futureproof agents getting set to other statuses during the action (e.g. captured / dead)
			if agent.current_status == Enums.CharacterStatus.ASSIGNED:
				agent.current_status = Enums.CharacterStatus.AVAILABLE

	# Store the logs for this turn
	turn_logs.append(current_turn_log)
	# Clear the actions list for the next turn
	actions.clear()

	# Clear the current turn log
	current_turn_log = []

	# Emit the signal to end the turn
	end_turn_complete.emit(turn_number)

# Method to get the log for a specific turn
func get_turn_log(turn: int) -> Array:
	if turn < 1 or turn > turn_logs.size():
		return []
	return turn_logs[turn - 1]  # Return the log for the specified turn
	
func remove_action(action: Action) -> void:
	# set all agents back to available
	for agent in action.characters:
		agent.current_status = Enums.CharacterStatus.AVAILABLE

	# remove the action from the list
	actions.erase(action)
	agent_changed.emit(action.characters[0])

func remove_all_actions_for_character(character: Character) -> void:
	for action in actions:
		if character in action.characters:
			# remove character from action
			action.characters.erase(character)
			# set character back to available
			character.current_status = Enums.CharacterStatus.AVAILABLE
			# if no more characters in action, remove action
			if action.characters.size() == 0:
				actions.erase(action)
	agent_changed.emit(character)

#region District and PoIs

func register_district(district: District) -> void:
	districts.append(district)
	emit_signal("new_district_registered", district)

func set_district_focused(district: District = null) -> void:
	if district_focused == district:
		return
	district_focused = district
	emit_signal("district_just_focused", district)

func set_menu_open(menu_id: String) -> void:
	if menus_open.has(menu_id):
		return
	menus_open.append(menu_id)

func set_menu_closed(menu_id: String) -> void:
	if !menus_open.has(menu_id):
		return
	menus_open.erase(menu_id)

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

#endregion

func get_resistance_level() -> int:
	var population = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	var keys = population.keys()
	var resistance_level = 0

	for key in keys:
		var character = population[key]
		resistance_level += character.sympathy

	return resistance_level / keys.size()

func get_heat_level() -> int:
	if districts.size() == 0:
		return 0
	var heat = 0
	for district in districts:
		heat += district.heat
	
	return floor(heat / districts.size())

func add_agent(agent: Character) -> void:
	agent_changed.emit(agent)

func remove_agent(agent: Character) -> void:
	agent_changed.emit(agent)

func get_actions() -> Array[Action]:
	return actions



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
