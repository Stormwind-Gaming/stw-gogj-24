extends Control

var character_list_scene = preload("res://scenes/gui/character_list.tscn")
@onready var show_character_list_button = $MarginContainer/LeftVBoxContainer/PanelContainer3/MarginContainer/VBoxContainer/CharacterListButton

func set_town_name(town_name) -> void:
	$MarginContainer/LeftVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TownName.text = "Town Name: " + town_name

func _ready():
	# Connect the button's "pressed" signal to a function using Callable
	show_character_list_button.connect("pressed", Callable(self, "_on_show_character_list_button_pressed"))

func _on_show_character_list_button_pressed():
	# Instance the character list scene
	var character_list_instance = character_list_scene.instantiate()
	
		# Add the instance to the scene tree
	add_child(character_list_instance)

	# Center the window on the screen using popup_centered()
	character_list_instance.popup_centered()
	
func add_character_card(character_id: String) -> void:
	# get character from store
	var local_character = GlobalRegistry.get_object(GlobalRegistry.Registry_Category.CHARACTER, character_id)
	var agent_card = Globals.agent_card_scene.instantiate()
	agent_card.character_id = character_id
	agent_card.character_name = local_character.get_full_name()
	$MarginContainer/LeftVBoxContainer/PanelContainer2/MarginContainer/GridContainer.add_child(agent_card)
	
