extends Node2DWithCleanup
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
var expires_on_turn: int = -1

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the object is initialized.
Registers the intel with the global registry and connects to turn end signal.
"""
func _init():
	LogDuck.d("Initializing base intel")

	# Listen to turn end
	EventBus.end_turn_complete.connect(_expire_intel)

	LogDuck.d("Base intel initialized", {
		"id": id,
		"expires_on": expires_on_turn
	})

"""
@brief Called when the object is being deleted.
Unregisters the intel from the global registry.

@param what The notification type being received
"""
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		LogDuck.d("Removing intel from registry", {
			"id": id,
			"type": self.get_class()
		})
		if ReferenceGetter.global_registry():
			ReferenceGetter.global_registry().intel.remove_item(self)
		
		if EventBus.end_turn_complete.is_connected(_expire_intel):
			EventBus.end_turn_complete.disconnect(_expire_intel)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the end of turn event.
Checks if the intel should expire and frees it if necessary.

@param turn_number The current turn number
"""
func _expire_intel(turn_number: int) -> void:
	LogDuck.d("Checking intel expiration", {
		"id": id,
		"current_turn": turn_number,
		"expires_on": expires_on_turn
	})

	# Check for associated action
	var action = ReferenceGetter.global_registry().actions.find_item(ReferenceGetter.global_registry().LIST_ALL_ACTIONS, "associated_plan", self)
	if action and action.in_flight:
		LogDuck.d("Intel expiration skipped - has active action", {
			"id": id,
			"action_type": action.action_type
		})
		return

	if expires_on_turn <= turn_number and not expires_on_turn == -1:
		LogDuck.d("Intel expired", {
			"id": id,
			"type": self.get_class(),
			"expired_on_turn": turn_number
		})
		self.call_deferred("free")
