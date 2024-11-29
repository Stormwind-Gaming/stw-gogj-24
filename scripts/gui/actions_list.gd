extends Window

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Container for the list of actions
"""
@export var actions_list: VBoxContainer

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Generates the initial action list.
"""
func _ready() -> void:
	_generate_action_list()

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the close button press event.
Notifies the GameController and removes this window.
"""
func _on_close_button_pressed() -> void:
	EventBus.close_window.emit()

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Generates the list of actions.
Clears existing actions and creates new action cards for each active action.
"""
func _generate_action_list() -> void:
	# clear the list
	for child in actions_list.get_children():
		child.queue_free()
	
	var actions = ReferenceGetter.global_registry().actions.get_list(ReferenceGetter.global_registry().LIST_ALL_ACTIONS)

	# for each action, create a new action card
	for action in actions:
		var actions_list_action = Globals.actions_list_action_scene.instantiate()
		actions_list_action.set_action(action)
		actions_list_action.connect("remove_action", _generate_action_list)
		actions_list.add_child(actions_list_action)
	
	if len(actions) == 0:
		# create a label to indicate no actions
		var margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_top", 5)
		margin_container.add_theme_constant_override("margin_left", 15)
		var label = Label.new()
		label.text = "No actions available, assign agents on the map to create actions."
		margin_container.add_child(label)
		actions_list.add_child(margin_container)
	
	# center the window
	popup_centered()
	
	# show the window
	show()
