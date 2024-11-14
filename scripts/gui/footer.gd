extends Control

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Button that shows the actions list
"""
@export var show_actions_list_button: Button

"""
@brief Button that shows the character list
"""
@export var show_character_list_button: Button

"""
@brief Button that shows the intel list
"""
@export var show_intel_list_button: Button

"""
@brief Button that shows the log list
"""
@export var show_log_list_button: Button

"""
@brief Button that ends the current turn
"""
@export var turn_button: Button

#|==============================|
#|          Signals            |
#|==============================|
"""
@brief Emitted when any menu is opened
"""
signal menu_opened

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Connects button signals to their respective handlers.
"""
func _ready():
	show_actions_list_button.connect("pressed", Callable(self, "_on_show_actions_list_button_pressed"))
	show_character_list_button.connect("pressed", Callable(self, "_on_show_character_list_button_pressed"))
	show_intel_list_button.connect("pressed", Callable(self, "_on_show_intel_list_button_pressed"))
	show_log_list_button.connect("pressed", Callable(self, "_on_show_log_list_button_pressed"))
	turn_button.connect("pressed", Callable(self, "_on_turn_button_pressed"))

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the show actions list button press.
Creates and displays the actions list if not already visible.
"""
func _on_show_actions_list_button_pressed():
	# if we already have an instance of the actions list, don't create a new one
	if get_node("ActionsList") != null:
		return
	
	# Instance the actions list scene
	var actions_list_instance = Globals.actions_list_scene.instantiate()
	
	# Add the instance to the scene tree
	add_child(actions_list_instance)

	_clear_focus()
	_update_menu_open("ActionsList")

"""
@brief Handles the show intel list button press.
Creates and displays the intel list if not already visible.
"""
func _on_show_intel_list_button_pressed():
	# if we already have an instance of the intel list, don't create a new one
	if get_node("IntelList") != null:
		return
	
	# Instance the intel list scene
	var intel_list_instance = Globals.intel_list_scene.instantiate()
	
	# Add the instance to the scene tree
	add_child(intel_list_instance)

	_clear_focus()
	_update_menu_open("IntelList")

"""
@brief Handles the show character list button press.
Creates and displays the character list if not already visible.
"""
func _on_show_character_list_button_pressed():
	# if we already have an instance of the character list, don't create a new one
	if get_node("CharacterList") != null:
		return
	
	# Instance the character list scene
	var character_list_instance = Globals.character_list_scene.instantiate()
	
	# Add the instance to the scene tree
	add_child(character_list_instance)

	_clear_focus()
	_update_menu_open("CharacterList")

"""
@brief Handles the show log list button press.
Creates and displays the log list if not already visible.

@param end_turn_button Whether this log list is being shown after ending a turn
"""
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

	_clear_focus()
	_update_menu_open("LogList")

"""
@brief Handles the turn button press.
Processes the turn and shows the end turn log.
"""
func _on_turn_button_pressed():
	GameController.process_turn()
	_on_show_log_list_button_pressed(true)

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Emits the menu_opened signal to clear focus from other UI elements.
"""
func _clear_focus() -> void:
	menu_opened.emit()

"""
@brief Updates the GameController with which menu is currently open.

@param id The identifier of the opened menu
"""
func _update_menu_open(id: String) -> void:
	GameController.set_menu_open(id)
