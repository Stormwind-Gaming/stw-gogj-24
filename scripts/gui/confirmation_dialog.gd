extends ConfirmationDialog

"""
How to instanciate in another script:

	var dialog = Globals.confirmation_dialog_scene.instantiate()
	dialog.setup_dialog('test', 'yes', 'no')
	dialog.connect("on_confirmed", _on_confirmed_fn)
	dialog.connect("on_canceled", _on_canceled_fn)
	add_child(dialog)
"""

@export var text: Label

signal on_confirmed()
signal on_canceled()

func setup_dialog(text: String, accept_text: String = 'Accept', cancel_button: String = 'Cancel') -> void:
	self.text.text = text

	## these are opposites because the accept button is on the left and the cancel button is on the right
	## so I've switched them
	self.ok_button_text = cancel_button
	self.cancel_button_text = accept_text

	# center the dialog
	self.popup_centered()


## switched, as before
func _on_canceled() -> void:
	on_confirmed.emit()
	# close the dialog
	queue_free()

func _on_confirmed() -> void:
	on_canceled.emit()
	# close the dialog
	queue_free()
