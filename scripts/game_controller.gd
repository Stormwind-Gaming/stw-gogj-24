extends Object

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
	var new_action = Action.new(poi, character, action_type, additional_info)
	actions.append(new_action)

# Method to process a turn
func process_turn() -> void:
	turn_number += 1  # Increment the turn number
	var current_turn_log: Array = []  # Array to store logs for this turn

	for action in actions:
		var log_message: String
		match action.action_type:
			ActionType.ESPIONAGE:
				log_message = "Processing ESPIONAGE action at " + str(action.poi) + " by " + str(action.character)
				if "second_character" in action.additional_info:
					log_message += ". Involves second character: " + str(action.additional_info["second_character"])
				# Implement ESPIONAGE logic here
				current_turn_log.append(log_message)
				print(log_message)  # Output to the console

	# Store the logs for this turn
	turn_logs.append(current_turn_log)
	# Clear the actions list for the next turn
	actions.clear()

# Method to get the log for a specific turn
func get_turn_log(turn: int) -> Array:
	if turn < 1 or turn > turn_logs.size():
		return []
	return turn_logs[turn - 1]  # Return the log for the specified turn
