extends PanelContainer

@export var character_texture: TextureRect
@export var charm_label: Label
@export var subtlety_label: Label
@export var smarts_label: Label

var character : Character

signal agent_card_selected(character: Character)

func _ready():
	$MarginContainer/VBoxContainer/Label.text = character.first_name + " " + character.last_name
	
	var picture_texture = load(character.picture)
	character_texture.texture = picture_texture

func _on_TextureButton_pressed():
	$MarginContainer/VBoxContainer/Panel.visible = true  # Show the border on press

func _on_TextureButton_released():
	$MarginContainer/VBoxContainer/Panel.visible = false  # Hide the border when released

func set_character(character_id: String):
	character = GlobalRegistry.get_object(Enums.Registry_Category.CHARACTER, character_id)
	charm_label.text = str(character.charm)
	subtlety_label.text = str(character.subtlety)
	smarts_label.text = str(character.smarts)

func disable_card() -> void:
	$TextureButton.disabled = true

func enable_card() -> void:
	$TextureButton.disabled = false

func _on_texture_button_toggled(toggled_on: bool) -> void:
	emit_signal('agent_card_selected', character, toggled_on)
