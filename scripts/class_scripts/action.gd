extends Node
class_name Action

#|==============================|
#|         Properties           |
#|==============================|
"""
@brief The Point of Interest where this action takes place
"""
var poi: PointOfInterest

"""
@brief Array of characters involved in this action
"""
var characters: Array[Character]

"""
@brief The type of action being performed
"""
var action_type: Enums.ActionType

"""
@brief Optional additional information for the action
Contains contextual data such as secondary characters or specific targets
"""
var additional_info: Dictionary = {}

"""
@brief The turn number when this action will end
"""
var turn_to_end: int = 0

"""
@brief The turn number when this action will expire if not completed
"""
var turn_to_expire: int = 0

"""
@brief The intelligence plan associated with this action
"""
var associated_plan: Intel = null

#|==============================|
#|        Initialization        |
#|==============================|
"""
@brief Initializes a new Action instance.

@param poi The Point of Interest where the action takes place
@param characters Array of characters involved in the action
@param action_type The type of action being performed
@param additional_info Optional dictionary containing extra information
"""
func _init(poi: PointOfInterest, characters: Array[Character], action_type: Enums.ActionType, additional_info: Dictionary = {}):
	self.poi = poi
	self.characters = characters
	self.action_type = action_type
	self.additional_info = additional_info
