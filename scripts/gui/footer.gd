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

"""
@brief Container indicating new items in the actions list
"""
@export var log_list_new_items_container: MarginContainer

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
	EventBus.open_new_window.emit(actions_list_instance)

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
	EventBus.open_new_window.emit(intel_list_instance)

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
	EventBus.open_new_window.emit(character_list_instance)

"""
@brief Handles the show log list button press.
Creates and displays the log list if not already visible.

@param end_turn_button Whether this log list is being shown after ending a turn
"""
func _on_show_log_list_button_pressed(end_turn_button: bool = false):
	# log_list_new_items_container.visible = false
	# if we already have an instance of the log list, don't create a new one
	if get_node("LogList") != null:
		return

	# Instance the log list scene
	var log_list_instance = Globals.log_list_scene.instantiate()
	if end_turn_button:
		log_list_instance.is_end_turn_log()
	
	# Add the instance to the scene tree
	EventBus.open_new_window.emit(log_list_instance)

"""
@brief Handles the turn button press.
Processes the turn and shows the end turn log.
"""
func _on_turn_button_pressed():
	# check if the player has unassigned agents
	for agent in GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED):
		if agent.char_state == Enums.CharacterState.AVAILABLE:
			# if so, show a warning and return
			var popup = Globals.confirmation_dialog_scene.instantiate()
			popup.setup_dialog("You have unassigned agents. Are you sure you want to end the turn?", "End Turn", "Cancel")
			popup.on_confirmed.connect(_on_turn_confirmed)
			add_child(popup)
			return
	_on_turn_confirmed()

"""
@brief Handles the turn confirmation.
Processes the turn and shows the end turn log.
"""
func _on_turn_confirmed():
	GameController.process_turn()
	# log_list_new_items_container.visible = true
	_on_show_log_list_button_pressed(true)
