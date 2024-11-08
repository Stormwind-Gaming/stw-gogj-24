extends Control

var character_list_scene = preload("res://scenes/gui/character_list.tscn")
var intel_list_scene = preload("res://scenes/gui/intel_list.tscn")
var log_list_scene = preload("res://scenes/gui/log_list.tscn")

@onready var show_character_list_button = $HBoxContainer/PanelContainer3/HBoxContainer/CharacterListButton
@onready var show_intel_list_button = $HBoxContainer/PanelContainer3/HBoxContainer/IntelListButton
@onready var show_log_list_button = $HBoxContainer/PanelContainer3/HBoxContainer/LogListButton
@onready var turn_button = $HBoxContainer/PanelContainer/TurnButton
@onready var date = $HBoxContainer/PanelContainer2/HBoxContainer/Date

func _ready():
	# Connect the button's "pressed" signal to a function using Callable
	show_character_list_button.connect("pressed", Callable(self, "_on_show_character_list_button_pressed"))
	show_intel_list_button.connect("pressed", Callable(self, "_on_show_intel_list_button_pressed"))
	show_log_list_button.connect("pressed", Callable(self, "_on_show_log_list_button_pressed"))

	turn_button.connect("pressed", Callable(self, "_on_turn_button_pressed"))


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
	
func _on_show_log_list_button_pressed():
	# Instance the log list scene
	var log_list_instance = log_list_scene.instantiate()
	
	# Add the instance to the scene tree
	add_child(log_list_instance)

	# Center the window on the screen using popup_centered()
	log_list_instance.popup_centered()
	
func _on_turn_button_pressed():
	GameController.process_turn()
	_on_show_log_list_button_pressed()
	var num = 13 + GameController.turn_number
	
	date.text = "Current Date: " + str(num) + " January 1942"
	
