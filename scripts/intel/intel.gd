extends Object

class_name Intel

var level: Enums.IntelLevel
var type: Enums.IntelType
var description: String
var id: String

#TODO: How do we store related time & thing? Maybe store the turn that its going to relate to as an int?
var related_character : Character
var related_poi : PointOfInterest
var related_item : Item

func _init(level: Enums.IntelLevel, type: Enums.IntelType, description: String):
	
	self.level = level
	self.type = type
	self.description = description
	self.id = GlobalRegistry.register_object(GlobalRegistry.Registry_Category.INTEL, self)
	
	print("Added intel to global registry")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		GlobalRegistry.unregister_object(GlobalRegistry.Registry_Category.INTEL, self.id)
		print("Removed intel from global registry")
