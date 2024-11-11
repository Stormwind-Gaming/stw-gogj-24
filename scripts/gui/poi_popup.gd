extends Window

@export var title_label: Label
@export var text_label: RichTextLabel

func set_details(title: String, text: String) -> void:
	title_label.text = title
	text_label.text = text
