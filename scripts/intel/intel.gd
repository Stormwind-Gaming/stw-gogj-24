extends Object

class_name Intel

var level: Enums.IntelLevel
var type: Enums.IntelType
var description: String
var effect = [Enums.IntelEffect.NONE]
var id: String

var related_character : Character
var related_poi : PointOfInterest
var related_duration: int
var related_expiry: int

var expires_on_turn : int

func _init(profile: Dictionary):
	for key in profile:
		if profile.has(key):
			if key == "effect":
				self.effect = profile[key]
			else:
				set(key, profile[key])
		
	# Register the object after setting properties
	self.id = GlobalRegistry.register_object(Enums.Registry_Category.INTEL, self)
	
	print("Added intel to global registry")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		GlobalRegistry.unregister_object(Enums.Registry_Category.INTEL, self.id)
		print("Removed intel from global registry")
