extends Node

# Enum for the types of actions
enum ActionType { ESPIONAGE } 

# Structure to store each action
class Action:
	var poi: PointOfInterest  # Point of Interest
	var character: Character  # Character involved
	var action_type: ActionType  # Type of action
	var additional_info: Dictionary = {}  # Optional additional information, e.g., a second character

	# Constructor for the Action class
	func _init(poi: PointOfInterest, character: Character, action_type: ActionType, additional_info: Dictionary = {}):
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
func add_action(poi: PointOfInterest, character: Character, action_type: ActionType, additional_info: Dictionary = {}) -> void:
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
			ActionType.ESPIONAGE:
				print("Action: ", action.poi, action.character)
				log_message = "Processing ESPIONAGE action at " + str(action.poi) + " by " + str(action.character)
				current_turn_log.append(log_message)
				
				# TODO: Implement ESPIONAGE logic here
				if(_bounded_sigmoid_check(action.character.subtlety)):
					log_message = "Succeeded subtlety check..."
					current_turn_log.append(log_message)
					
					match action.poi.stat_check_type:
						Enums.StatCheckType.SMARTS:
							if(_bounded_sigmoid_check(action.character.smarts)):
								log_message = "Succeeded smarts check..."
								current_turn_log.append(log_message)
								success = true
							else: 
								log_message = "Failed smarts check..."
								current_turn_log.append(log_message)
						Enums.StatCheckType.CHARM:
							if(_bounded_sigmoid_check(action.character.charm)):
								log_message = "Succeeded charm check..."
								current_turn_log.append(log_message)
								success = true
							else: 
								log_message = "Failed charm check..."
								current_turn_log.append(log_message)
				
				
		if success:
			log_message = "The mission was a success!"
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

# Method to get the log for a specific turn
func get_turn_log(turn: int) -> Array:
	if turn < 1 or turn > turn_logs.size():
		return []
	return turn_logs[turn - 1]  # Return the log for the specified turn
	
func _bounded_sigmoid_check(stat: int, bottom_bound: float = 20.0, upper_bound: float = 80.0) -> bool:
	# Calculate the sigmoid-based success chance
	var k = 1.0  # Steepness of the curve
	var m = 5.0  # Midpoint of the curve
	var raw_chance = 100 / (1 + exp(-k * (stat - m)))
	
	# Scale the raw chance to fit within the bottom and upper bounds
	var success_chance = bottom_bound + (upper_bound - bottom_bound) * (raw_chance / 100)

	# Roll a random number between 0 and 100 and compare to the success chance
	var roll = randf() * 100
	return roll < success_chance
