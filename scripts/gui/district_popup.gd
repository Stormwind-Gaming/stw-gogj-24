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
@export var sympathy_label: RichTextLabel

#|==============================|
#|      Setters & Getters      |
#|==============================|
"""
@brief Sets the title and text content of the popup.

@param title The title to display at the top of the popup
@param text The main text content to display in the popup body
"""
func set_initial_details(popup_title: String, text: String, heat: float, sympathy: float) -> void:
	title_label.text = popup_title
	text_label.text = text
	heat_label.text = ("Heat: %s" % [str(round(heat))]) + "%"
	sympathy_label.text = "Sympathy: %s" % [str(round(sympathy)) + "%"]

func set_heat(heat: float) -> void:
	heat_label.text = ("Heat: %s" % [str(round(heat))]) + "%"

func set_sympathy(sympathy: float) -> void:
	sympathy_label.text = "Sympathy: %s" % [str(round(sympathy)) + "%"]
