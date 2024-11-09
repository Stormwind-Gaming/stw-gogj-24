extends Node

var district_focused: District = null

var poi_for_radial: PointOfInterest
var radial_menu_open: RadialMenu

signal end_turn(num: int)
signal district_just_focused(district: District)

# Structure to store each action
class Action:
	var poi: PointOfInterest  # Point of Interest
	var character: Character  # Character involved
	var action_type: Enums.ActionType  # Type of action
	var additional_info: Dictionary = {}  # Optional additional information, e.g., a second character

	# Constructor for the Action class
	func _init(poi: PointOfInterest, character: Character, action_type: Enums.ActionType, additional_info: Dictionary = {}):
		self.poi = poi
		self.character = character
		self.action_type = action_type
		self.additional_info = additional_info

# List to store all actions for the current turn
var actions: Array = []
# Variable to track the current turn number
var turn_number: int = 0
# Multidimensional array to log the output of each turn
var turn_logs: Array = []

# Method to add an action
func add_action(poi: PointOfInterest, character: Character, action_type: Enums.ActionType, additional_info: Dictionary = {}) -> void:
	print("Adding action:", poi, character, action_type)
	var new_action = Action.new(poi, character, action_type, additional_info)
	actions.append(new_action)


# Method to process a turn
func process_turn() -> void:
	turn_number += 1  # Increment the turn number
	var current_turn_log: Array = []  # Array to store logs for this turn

	for action in actions:
		var log_message: String
		var success: bool = false
		match action.action_type:
			Enums.ActionType.ESPIONAGE:
				print("Action: ", action.poi, action.character)
				log_message = "Processing ESPIONAGE action at " + str(action.poi.poi_name) + " by " + str(action.character.first_name + " " + action.character.last_name)
				current_turn_log.append(log_message)
				
				var subtle_roll = _bounded_sigmoid_check(action.character.subtlety, true)
				
				if(subtle_roll.success):
					log_message = "Succeeded subtlety check..." + str(subtle_roll)
					current_turn_log.append(log_message)
					
					match action.poi.stat_check_type:
						Enums.StatCheckType.SMARTS:
							
							var smarts_roll = _bounded_sigmoid_check(action.character.smarts, true)
							
							if(smarts_roll.success):
								log_message = "Succeeded smarts check..." + str(smarts_roll)
								current_turn_log.append(log_message)
								success = true
							else: 
								log_message = "Failed smarts check..." + str(smarts_roll)
								current_turn_log.append(log_message)
						Enums.StatCheckType.CHARM:
							if(_bounded_sigmoid_check(action.character.charm)):
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
			log_message = "The mission was a success!"
			print(IntelFactory)
			current_turn_log.append(log_message)
			IntelFactory.create_rumour(action.poi.rumour_config)
		else:
			log_message = "The mission was a failure! :("
			current_turn_log.append(log_message)

		
	# Output current turn log to the console		
	for each_log_message in current_turn_log:
		print(each_log_message)  

	# Store the logs for this turn
	turn_logs.append(current_turn_log)
	# Clear the actions list for the next turn
	actions.clear()

	# Emit the signal to end the turn
	emit_signal("end_turn", turn_number)

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

	if option == Enums.ActionType.NONE:
		return
	
	if option == Enums.ActionType.INFO:
		print("Showing info for POI: ", poi_for_radial)
		# poi_for_radial.show_info()
		return

	# popup a post_radial_assignment menu
	var post_radial_assignment = Globals.post_radial_assignment_scene.instantiate()
	post_radial_assignment.set_option(option)
	post_radial_assignment.connect('post_radial_assignment_option', _on_post_radial_assignment_option_selected)
	add_child(post_radial_assignment)

func _on_post_radial_assignment_option_selected(option: Enums.ActionType) -> void:
	if option != Enums.ActionType.NONE:
		var characters = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
		GameController.add_action(poi_for_radial, characters[characters.keys().front()], option)

	# create a tiny timer to get around erroneous clickthroughs
	await get_tree().create_timer(0.1).timeout
	radial_menu_open.queue_free()
	radial_menu_open = null

#endregion
