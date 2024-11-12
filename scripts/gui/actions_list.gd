extends Window

@export var actions_list: VBoxContainer

func _ready() -> void:
	_generate_action_list()

func _on_close_button_pressed() -> void:
	GameController.set_menu_closed("ActionsList")
	queue_free()

func _generate_action_list() -> void:
	# clear the list
	for child in actions_list.get_children():
		child.queue_free()
	
	# for each action, create a new action card
	for action in GameController.actions:
		var actions_list_action = Globals.actions_list_action_scene.instantiate()
		actions_list_action.set_action(action)
		actions_list_action.connect("remove_action", _generate_action_list)
		actions_list.add_child(actions_list_action)
	
	# center the window
	popup_centered()
	
	# show the window
	show()
