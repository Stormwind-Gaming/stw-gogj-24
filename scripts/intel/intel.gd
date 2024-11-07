extends Object

class_name Intel

var level: Enums.IntelLevel
var type: Enums.IntelType
var description: String

func _init(level: Enums.IntelLevel, type: Enums.IntelType, description: String):
	
	self.level = level
	self.type = type
	self.description = description
	
	GlobalRegistry.register_object('intel', self)


func gather():
	print("Gathering intel: " + description)
