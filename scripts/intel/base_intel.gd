extends Object
class_name BaseIntel

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Unique identifier for this intel object
"""
var id: String

"""
@brief Turn number when this intel will expire
"""
var expires_on_turn: int

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the object is initialized.
Registers the intel with the global registry and connects to turn end signal.
"""
func _init():
	print('BaseIntel init')

	# self.id = GlobalRegistry.register_object(Enums.Registry_Category.INTEL, self)

	# Listen to turn end
	GameController.end_turn_complete.connect(_expire_intel)

"""
@brief Called when the object is being deleted.
Unregisters the intel from the global registry.

@param what The notification type being received
"""
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		GlobalRegistry.unregister_object(Enums.Registry_Category.INTEL, self.id)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the end of turn event.
Checks if the intel should expire and frees it if necessary.

@param turn_number The current turn number
"""
func _expire_intel(turn_number: int) -> void:
	if expires_on_turn <= turn_number:
		self.call_deferred("free")