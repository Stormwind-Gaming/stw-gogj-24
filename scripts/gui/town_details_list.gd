extends Window


func _on_close_button_pressed() -> void:
	EventBus.close_window.emit()
