extends Node2D
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
	print('BaseIntel init')

	# self.id = GlobalRegistry.register_object(Enums.Registry_Category.INTEL, self)

	# Listen to turn end
	EventBus.end_turn_complete.connect(_expire_intel)

"""
@brief Called when the object is being deleted.
Unregisters the intel from the global registry.

@param what The notification type being received
"""
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		GlobalRegistry.intel.remove_item(self)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the end of turn event.
Checks if the intel should expire and frees it if necessary.

@param turn_number The current turn number
"""
func _expire_intel(turn_number: int) -> void:

	# If plan has an in flight action then dont expire it
	var action = GlobalRegistry.actions.find_item(GlobalRegistry.LIST_ALL_ACTIONS, "associated_plan", self)
	if action and action.in_flight:
		return

	if expires_on_turn <= turn_number and not expires_on_turn == -1:
		self.call_deferred("free")