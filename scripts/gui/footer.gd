extends Control

var character_list_scene = preload("res://scenes/gui/character_list.tscn")
var intel_list_scene = preload("res://scenes/gui/intel_list.tscn")

@onready var show_character_list_button = $HBoxContainer/PanelContainer3/HBoxContainer/CharacterListButton
@onready var show_intel_list_button = $HBoxContainer/PanelContainer3/HBoxContainer/IntelListButton


func _ready():
	# Connect the button's "pressed" signal to a function using Callable
	show_character_list_button.connect("pressed", Callable(self, "_on_show_character_list_button_pressed"))
	
	show_intel_list_button.connect("pressed", Callable(self, "_on_show_intel_list_button_pressed"))

func _on_show_intel_list_button_pressed():
	# Instance the intel list scene
	var intel_list_instance = intel_list_scene.instantiate()
	
		# Add the instance to the scene tree
	add_child(intel_list_instance)

	# Center the window on the screen using popup_centered()
	intel_list_instance.popup_centered()


func _on_show_character_list_button_pressed():
	# Instance the character list scene
	var character_list_instance = character_list_scene.instantiate()
	
		# Add the instance to the scene tree
	add_child(character_list_instance)

	# Center the window on the screen using popup_centered()
	character_list_instance.popup_centered()
