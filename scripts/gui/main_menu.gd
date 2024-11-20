extends Control

#|==============================|
#|      Event Handlers          |
#|==============================|
"""
@brief Button to start a new game
"""
func _on_new_game_button_pressed() -> void:
	$AnimationPlayer.play("fade_out")
	$AnimationPlayer.animation_finished.connect(_show_new_game_screen)

"""
@brief Shows the new game screen

@param name The name of the animation that finished
"""
func _show_new_game_screen(name: String) -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")

"""
@brief Button to open the options menu
"""
func _on_options_button_pressed() -> void:
	pass # Replace with function body.

"""
@brief Button to quit the game
"""
func _on_quit_button_pressed() -> void:
	get_tree().quit()
