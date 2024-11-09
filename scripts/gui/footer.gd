extends Control

@export var show_character_list_button: Button
@export var show_intel_list_button: Button
@export var show_log_list_button: Button
@export var show_agents_list_button: Button
@export var turn_button: Button

func _ready():
	# Connect the button's "pressed" signal to a function using Callable
	show_character_list_button.connect("pressed", Callable(self, "_on_show_character_list_button_pressed"))
	show_intel_list_button.connect("pressed", Callable(self, "_on_show_intel_list_button_pressed"))
	show_log_list_button.connect("pressed", Callable(self, "_on_show_log_list_button_pressed"))

	turn_button.connect("pressed", Callable(self, "_on_turn_button_pressed"))


func _on_tab_bar_tab_clicked(tab: int) -> void:
	match tab:
		0:
			# _on_show_agents_list_button_pressed()
			pass
		1:
			_on_show_intel_list_button_pressed()
		2:
			_on_show_character_list_button_pressed()
		3:
			_on_show_log_list_button_pressed()
		_:
			pass


func _on_show_intel_list_button_pressed():
	# if we already have an instance of the intel list, don't create a new one
	if get_node("IntelList") != null:
		return
	
	# Instance the intel list scene
	var intel_list_instance = Globals.intel_list_scene.instantiate()
	
		# Add the instance to the scene tree
	add_child(intel_list_instance)

	# Center the window on the screen using popup_centered()
	intel_list_instance.popup_centered()


func _on_show_character_list_button_pressed():
	# if we already have an instance of the character list, don't create a new one
	if get_node("CharacterList") != null:
		return
	
	# Instance the character list scene
	var character_list_instance = Globals.character_list_scene.instantiate()
	
		# Add the instance to the scene tree
	add_child(character_list_instance)

	# Center the window on the screen using popup_centered()
	character_list_instance.popup_centered()
	
func _on_show_log_list_button_pressed():
	# if we already have an instance of the log list, don't create a new one
	if get_node("LogList") != null:
		return

	# Instance the log list scene
	var log_list_instance = Globals.log_list_scene.instantiate()
	
	# Add the instance to the scene tree
	add_child(log_list_instance)

	# Center the window on the screen using popup_centered()
	log_list_instance.popup_centered()
	
func _on_turn_button_pressed():
	GameController.process_turn()
	_on_show_log_list_button_pressed()
	var num = 13 + GameController.turn_number	
