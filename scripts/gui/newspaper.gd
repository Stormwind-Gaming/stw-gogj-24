extends PopupPanel

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief label for the town name
"""
@export var town_label: Label

"""
@brief Label for the date
"""
@export var date_label: Label

"""
@brief RichTextLabel container for the note content
"""
@export var note_content: RichTextLabel


#|==============================|
#|      Methods       			   |
#|==============================|
"""
@brief Refresh the newspaper with the current town name and date
"""
func _refresh_newspaper():
	town_label.text = "%s, België" % ReferenceGetter.game_controller().get_town_name()
	date_label.text = ReferenceGetter.game_controller().calendar.get_date_string()

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Set the note title and content

@param title: The title of the note
content: The content of the note
"""
func set_note(content: String) -> void:
	_refresh_newspaper()
	note_content.clear()
	note_content.text = content
	pass
	

#|==============================|
#|      Event Handlers         |
#|==============================|

"""
@brief Handle the close button being pressed
"""
func _on_close_button_pressed() -> void:
	queue_free()
