extends Node

var district_focused: District = null

var poi_for_radial: PointOfInterest
var radial_menu_open: RadialMenu
var districts: Array[District] = []
var calendar: Calendar

signal end_turn_initiated(num: int)
signal end_turn_complete(num: int)
signal district_just_focused(district: District)
signal new_district_registered(district: District)
signal agent_added(agent: Character)
signal agent_removed(agent: Character)
signal new_assignment(option: Enums.ActionType, poi: PointOfInterest, agents: Array[Character])

func _ready() -> void:
	calendar = Calendar.new()

# Structure to store each action
class Action:
	var poi: PointOfInterest  # Point of Interest
	var characters: Array[Character]  # Character involved
	var action_type: Enums.ActionType  # Type of action
	var additional_info: Dictionary = {}  # Optional additional information, e.g., a second character

	# Constructor for the Action class
	func _init(poi: PointOfInterest, characters: Array[Character], action_type: Enums.ActionType, additional_info: Dictionary = {}):
		self.poi = poi
		self.characters = characters
		self.action_type = action_type
		self.additional_info = additional_info

# List to store all actions for the current turn
var actions: Array[Action] = []
# Variable to track the current turn number
var turn_number: int = 0
# Multidimensional array to log the output of each turn
var turn_logs: Array = []

# Method to add an action
func add_action(poi: PointOfInterest, characters: Array[Character], action_type: Enums.ActionType, additional_info: Dictionary = {}) -> void:
	# check if this character is already assigned to an action
	for action in actions:
		for existing_action_character in action.characters:
			for new_action_character in characters:
				if existing_action_character == new_action_character:
					# delete the previous action
					_remove_action(action)

	print("Adding action:", poi, characters, action_type)
	var new_action = Action.new(poi, characters, action_type, additional_info)
	actions.append(new_action)


# Method to process a turn
func process_turn() -> void:
	end_turn_initiated.emit(turn_number)  # Emit the end turn signal

	turn_number += 1  # Increment the turn number
	calendar.increment_day()  # Increment the day
	var current_turn_log: Array = []  # Array to store logs for this turn

	for action in actions:
		var log_message: String
		var success: bool = false
		match action.action_type:
			Enums.ActionType.ESPIONAGE:
				print("Action: ", action.poi, action.characters)
				log_message = "Processing ESPIONAGE action at [u]" + str(action.poi.poi_name) + "[/u] by "
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
				
				var subtle_roll = _bounded_sigmoid_check(combined_subtlety, true)
				
				if(subtle_roll.success):
					log_message = "Succeeded subtlety check..." + str(subtle_roll)
					current_turn_log.append(log_message)
					
					match action.poi.stat_check_type:
						Enums.StatCheckType.SMARTS:
							
							var smarts_roll = _bounded_sigmoid_check(combined_smarts, true)
							
							if(smarts_roll.success):
								log_message = "Succeeded smarts check..." + str(smarts_roll)
								current_turn_log.append(log_message)
								success = true
							else: 
								log_message = "Failed smarts check..." + str(smarts_roll)
								current_turn_log.append(log_message)
						Enums.StatCheckType.CHARM:
							if(_bounded_sigmoid_check(combined_charm)):
								log_message = "Succeeded charm check..."
								current_turn_log.append(log_message)
								success = true
							else: 
								log_message = "Failed charm check..."
								current_turn_log.append(log_message)
				else:
					log_message = "Failed subtlety check..." + str(subtle_roll)
					current_turn_log.append(log_message)
				
				
		if success:
			log_message = "[color=green]The mission was a success![/color]"
			print(IntelFactory)
			current_turn_log.append(log_message)
			IntelFactory.create_rumour(action.poi.rumour_config)
		else:
			log_message = "[color=red]The mission was a failure! :([/color]"
			current_turn_log.append(log_message)

		
	# Output current turn log to the console		
	for each_log_message in current_turn_log:
		print(each_log_message)  

	# Store the logs for this turn
	turn_logs.append(current_turn_log)
	# Clear the actions list for the next turn
	actions.clear()

	# Emit the signal to end the turn
	end_turn_complete.emit(turn_number)

# Method to get the log for a specific turn
func get_turn_log(turn: int) -> Array:
	if turn < 1 or turn > turn_logs.size():
		return []
	return turn_logs[turn - 1]  # Return the log for the specified turn
	
func _bounded_sigmoid_check(stat: int, detailed: bool = false, bottom_bound: float = 20.0, upper_bound: float = 80.0) -> Variant:
	# Calculate the sigmoid-based success chance
	var k = 1.0  # Steepness of the curve
	var m = 5.0  # Midpoint of the curve
	var raw_chance = 100 / (1 + exp(-k * (stat - m)))
	
	# Scale the raw chance to fit within the bottom and upper bounds
	var success_chance = bottom_bound + (upper_bound - bottom_bound) * (raw_chance / 100)
	
	# Roll a random number between 0 and 100
	var roll = randf() * 100
	
	# Determine success
	var is_success = roll < success_chance
	
	# Return based on the 'detailed' flag
	if detailed:
		return {
			"success": is_success,
			"stat": stat,
			"raw_chance": raw_chance,
			"success_chance": success_chance,
			"roll": roll
		}
	else:
		return is_success

#region District and PoIs

func register_district(district: District) -> void:
	districts.append(district)
	emit_signal("new_district_registered", district)

func set_district_focused(district: District = null) -> void:
	if district_focused == district:
		return
	district_focused = district
	emit_signal("district_just_focused", district)


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
	print("_on_post_radial_assignment_option_selected")
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

func _remove_action(action: Action) -> void:
	# set all agents back to available
	for agent in action.characters:
		agent.current_status = Enums.CharacterStatus.AVAILABLE

	# remove the action from the list
	actions.erase(action)

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
	agent_added.emit(agent)

func remove_agent(agent: Character) -> void:
	agent_removed.emit(agent)
