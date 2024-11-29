extends WindowWithCleanup

"""
How to instanciate in another script:

	var dialog = Globals.confirmation_dialog_scene.instantiate()
	dialog.setup_dialog('test', 'yes', 'no')
	dialog.connect("on_confirmed", _on_confirmed_fn)
	dialog.connect("on_canceled", _on_canceled_fn)
	add_child(dialog)
"""

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Label that displays the dialog text
"""
@export var text: Label

"""
@brief Button for the accept button
"""
@export var accept_button: Button

"""
@brief Button for the cancel button
"""
@export var cancel_button: Button


#|==============================|
#|          Signals            |
#|==============================|
"""
@brief Emitted when the dialog is confirmed (accept button pressed)
"""
signal on_confirmed()

"""
@brief Emitted when the dialog is canceled (cancel button pressed)
"""
signal on_canceled()

#|==============================|
#|       Dialog Setup          |
#|==============================|
"""
@brief Sets up the confirmation dialog with custom text and button labels.

@param text The message to display in the dialog
@param accept_text Text for the accept button (default: 'Accept')
@param cancel_button Text for the cancel button (default: 'Cancel')
"""
func setup_dialog(text: String, accept_text: String = 'Accept', cancel_button: String = 'Cancel') -> void:
	self.text.text = text

	self.accept_button.text = accept_text
	self.cancel_button.text = cancel_button

	# center the dialog
	self.popup_centered()

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the cancel button press.
Note: Due to button position swap, this actually emits the confirmed signal.
"""
func _on_canceled() -> void:
	on_canceled.emit()
	# close the dialog
	queue_free()

"""
@brief Handles the confirm button press.
Note: Due to button position swap, this actually emits the canceled signal.
"""
func _on_confirmed() -> void:
	on_confirmed.emit()
	# close the dialog
	queue_free()
