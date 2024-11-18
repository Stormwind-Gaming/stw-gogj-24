extends Window

#|==============================|
#|      Event Handlers          |
#|==============================|
"""
@brief Button to resume the game
"""
func _on_resume_game_button_pressed() -> void:
	self.hide()

"""
@brief Button to open the options menu
"""
func _on_options_button_pressed() -> void:
	pass # Replace with function body.

"""
@brief Button to quit to the main menu
"""
func _on_quit_to_menu_button_pressed() -> void:
	# TODO: Reset the game state as currently it explodes on a new game 
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
