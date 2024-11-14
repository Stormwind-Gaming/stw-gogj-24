extends Object
class_name Intel

# var level: Enums.IntelLevel
# var type: Enums.IntelType
# var description: String
# var effect = [Enums.IntelEffect.NONE]
# var id: String
# var plan_name : String 

# var related_character : Character
# var related_poi : PointOfInterest
# var related_duration: int
# var related_expiry: int

# var expires_on_turn : int

# var plan_who_what: String
# var plan_where: String
# var plan_when: String

# func _init(profile: Dictionary):
# 	for key in profile:
# 		if profile.has(key):
# 			if key == "effect":
# 				self.effect = profile[key]
# 			else:
# 				set(key, profile[key])

# 	if(level == Enums.IntelLevel.PLAN):
# 		expires_on_turn = GameController.turn_number + related_expiry
# 	else:
# 		expires_on_turn = GameController.turn_number + 3
	
		
# 	# Register the object after setting properties
# 	self.id = GlobalRegistry.register_object(Enums.Registry_Category.INTEL, self)

# 	# Listen to turn end
# 	GameController.end_turn_complete.connect(_expire_intel)

# func _notification(what: int) -> void:
# 	if what == NOTIFICATION_PREDELETE:
# 		GlobalRegistry.unregister_object(Enums.Registry_Category.INTEL, self.id)

# func _expire_intel(num: int) -> void:
# 	if expires_on_turn <= GameController.turn_number:
# 		self.call_deferred("free")
