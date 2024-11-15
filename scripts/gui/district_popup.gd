extends Window

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Label that displays the district title
"""
@export var title_label: Label

"""
@brief RichTextLabel that displays the district details
"""
@export var text_label: RichTextLabel
@export var heat_label: RichTextLabel 

#|==============================|
#|      Setters & Getters      |
#|==============================|
"""
@brief Sets the title and text content of the popup.

@param title The title to display at the top of the popup
@param text The main text content to display in the popup body
"""
func set_initial_details(title: String, text: String, heat: float) -> void:
	title_label.text = title
	text_label.text = text
	heat_label.text = ("Heat: %s" % [str(round(heat))]) + "%"

func set_heat(heat: float) -> void:
	heat_label.text = ("Heat: %s" % [str(round(heat))]) + "%"
