extends Node
class_name Action

# Structure to store each action
var poi: PointOfInterest  # Point of Interest
var characters: Array[Character]  # Character involved
var action_type: Enums.ActionType  # Type of action
var additional_info: Dictionary = {}  # Optional additional information, e.g., a second character
var turn_to_end: int = 0  # Turn to end the action
var turn_to_expire: int = 0  # Turn to expire the action

# Constructor for the Action class
func _init(poi: PointOfInterest, characters: Array[Character], action_type: Enums.ActionType, additional_info: Dictionary = {}):
	self.poi = poi
	self.characters = characters
	self.action_type = action_type
	self.additional_info = additional_info