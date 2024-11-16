extends Window

#|==============================|
#|      Exported Variables       |
#|==============================|

@export var event_image: TextureRect
@export var title_label: Label
@export var text_label: RichTextLabel
@export var button: Button


#|==============================|
#|    Getters and Setters       |
#|==============================|
"""
@brief Sets the character for the agent card.

@param event_type The type of the event being displayed.
@param title The title of the event.
@param text The text of the event.
@param button_text The text of the button.
"""
func set_event_text(event_type: Enums.EventOutcomeType, title: String = "", text: String = "", button_text: String = "Ok") -> void:
	# get the event type image
	event_image.texture =  Globals.event_images[event_type]
	title_label.text = title
	text_label.text = text
	button.text = button_text

#|==============================|
#|       Event Listeners        |
#|==============================|

"""
@brief Handle the button being pressed
"""
func _on_button_pressed() -> void:
	queue_free()
