extends PanelContainer

var character : Character

func _ready():
	print(character.picture)  # Debug: Check the image path

	$MarginContainer/VBoxContainer/Label.text = character.first_name + " " + character.last_name
	
	var picture_texture = load(character.picture)
	$MarginContainer/VBoxContainer/TextureButton.texture_normal = picture_texture
	$MarginContainer/VBoxContainer/TextureButton.texture_hover = picture_texture
	$MarginContainer/VBoxContainer/TextureButton.texture_pressed = picture_texture
	$MarginContainer/VBoxContainer/TextureButton.texture_disabled = picture_texture

func _on_TextureButton_pressed():
	$MarginContainer/VBoxContainer/Panel.visible = true  # Show the border on press

func _on_TextureButton_released():
	$MarginContainer/VBoxContainer/Panel.visible = false  # Hide the border when released

func set_character(character_id:String):
	character = GlobalRegistry.get_object(GlobalRegistry.Registry_Category.CHARACTER, character_id)
