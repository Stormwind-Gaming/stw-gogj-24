extends Object

class_name Intel

var level: Enums.IntelLevel
var type: Enums.IntelType
var description: String
var id: String

func _init(level: Enums.IntelLevel, type: Enums.IntelType, description: String):
	
	self.level = level
	self.type = type
	self.description = description
	self.id = GlobalRegistry.register_object(Enums.Registry_Category.INTEL, self)
	
	print("Added intel to global registry")

func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
				GlobalRegistry.unregister_object(Enums.Registry_Category.INTEL, self.id)
				print("Removed intel from global registry")
