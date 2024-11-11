extends Control

@export var show_actions_list_button: Button
@export var show_character_list_button: Button
@export var show_intel_list_button: Button
@export var show_log_list_button: Button
@export var turn_button: Button

var footer_tray_open: bool = false

func _ready():
	# Connect the button's "pressed" signal to a function using Callable
	show_actions_list_button.connect("pressed", Callable(self, "_on_show_actions_list_button_pressed"))
	show_character_list_button.connect("pressed", Callable(self, "_on_show_character_list_button_pressed"))
	show_intel_list_button.connect("pressed", Callable(self, "_on_show_intel_list_button_pressed"))
	show_log_list_button.connect("pressed", Callable(self, "_on_show_log_list_button_pressed"))

	turn_button.connect("pressed", Callable(self, "_on_turn_button_pressed"))

func _on_show_actions_list_button_pressed():
	# if we already have an instance of the actions list, don't create a new one
	if get_node("ActionsList") != null:
		return
	
	# Instance the actions list scene
	var actions_list_instance = Globals.actions_list_scene.instantiate()
	
	# Add the instance to the scene tree
	add_child(actions_list_instance)

func _on_show_intel_list_button_pressed():
	# if we already have an instance of the intel list, don't create a new one
	if get_node("IntelList") != null:
		return
	
	# Instance the intel list scene
	var intel_list_instance = Globals.intel_list_scene.instantiate()
	
		# Add the instance to the scene tree
	add_child(intel_list_instance)


func _on_show_character_list_button_pressed():
	# if we already have an instance of the character list, don't create a new one
	if get_node("CharacterList") != null:
		return
	
	# Instance the character list scene
	var character_list_instance = Globals.character_list_scene.instantiate()
	
		# Add the instance to the scene tree
	add_child(character_list_instance)
	
func _on_show_log_list_button_pressed(end_turn_button: bool = false):
	# if we already have an instance of the log list, don't create a new one
	if get_node("LogList") != null:
		return

	# Instance the log list scene
	var log_list_instance = Globals.log_list_scene.instantiate()
	if end_turn_button:
		log_list_instance.is_end_turn_log()
	
	# Add the instance to the scene tree
	add_child(log_list_instance)
	
func _on_turn_button_pressed():
	GameController.process_turn()
	_on_show_log_list_button_pressed(true)
	var num = 13 + GameController.turn_number	
