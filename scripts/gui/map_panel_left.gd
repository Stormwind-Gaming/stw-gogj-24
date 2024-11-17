extends Control

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Scene instance for the character list
"""
var character_list_scene = preload("res://scenes/gui/character_list.tscn")

"""
@brief Button to show the character list
"""
@onready var show_character_list_button = $MarginContainer/LeftVBoxContainer/PanelContainer3/MarginContainer/VBoxContainer/CharacterListButton

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Connects button signals to their handlers.
"""
func _ready():
	# Connect the button's "pressed" signal to a function using Callable
	show_character_list_button.connect("pressed", Callable(self, "_on_show_character_list_button_pressed"))

#|==============================|
#|      Setters & Getters      |
#|==============================|
"""
@brief Sets the town name in the panel.

@param town_name The name of the town to display
"""
func set_town_name(town_name) -> void:
	$MarginContainer/LeftVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TownName.text = "Town Name: " + town_name

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the show character list button press.
Creates and displays the character list window.
"""
func _on_show_character_list_button_pressed():
	# Instance the character list scene
	var character_list_instance = character_list_scene.instantiate()
	
	# Add the instance to the scene tree
	add_child(character_list_instance)

	# Center the window on the screen using popup_centered()
	character_list_instance.popup_centered()

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Adds a character card to the panel.

@param character_id The unique identifier of the character to add
"""
func add_character_card(character_id: String) -> void:
	var agent_card = Globals.agent_card_scene.instantiate()
	agent_card.set_character(character_id)
	$MarginContainer/LeftVBoxContainer/PanelContainer2/MarginContainer/GridContainer.add_child(agent_card)
