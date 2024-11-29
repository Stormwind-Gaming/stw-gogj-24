extends Control

func _ready() -> void:
	_reset_game_state()


func _reset_game_state() -> void:
	# Reset the registry ready for a new game
	GlobalRegistry.reset()
	# Reset the GameController
	GameController.reset()
	# Reset the GameStats
	GameStats.reset()

#|==============================|
#|      Event Handlers          |
#|==============================|
"""
@brief Button to start a new game
"""
func _on_new_game_button_pressed() -> void:
	var audio_tween = create_tween()
	audio_tween.tween_property($AudioStreamPlayer2D, "volume_db", -80, 1.0).set_ease(Tween.EASE_OUT)
	$AnimationPlayer.play("fade_out")
	$AnimationPlayer.animation_finished.connect(_show_new_game_screen)

"""
@brief Shows the new game screen

@param name The name of the animation that finished
"""
func _show_new_game_screen(name: String) -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")

"""
@brief Button to open the tutorial
"""
func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gui/tutorial/tutorial.tscn")

"""
@brief Button to quit the game
"""
func _on_quit_button_pressed() -> void:
	get_tree().quit()