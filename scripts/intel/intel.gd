extends Object

class_name Intel

const Constants = preload("res://scripts/enums.gd")

var level: Constants.IntelLevel
var type: Constants.IntelType
var description: String

func _init(level: Constants.IntelLevel, type: Constants.IntelType, description: String):
	
	self.level = level
	self.type = type
	self.description = description
	
	GlobalRegistry.register_object('intel', self)


func gather():
	print("Gathering intel: " + description)
