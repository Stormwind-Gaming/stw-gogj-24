extends Window

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Label displaying the POI title
"""
@export var title_label: Label

"""
@brief Label displaying the POI description
"""
@export var text_label: RichTextLabel

#|==============================|
#|      Setters & Getters      |
#|==============================|
"""
@brief Sets the title and description text for the POI popup.

@param title The title of the Point of Interest
@param text The description text for the Point of Interest
"""
func set_details(title: String, text: String) -> void:
	title_label.text = title
	text_label.text = text
