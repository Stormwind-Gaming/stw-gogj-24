extends ControlWithCleanup

@export var sound_button: TextureButton


func _ready() -> void:
	_reset_game_state()

	# check if the sound is enabled
	if Globals.sound_enabled:
		_on_sound_button_toggled(true)
	else:
		_on_sound_button_toggled(false)

func _reset_game_state() -> void:
	# Reset the GlobalMilestones
	GlobalMilestones.reset()
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
	get_tree().change_scene_to_file("res://scenes/gui/tutorial/tutorial_map.tscn")

"""
@brief Button to quit the game
"""
func _on_quit_button_pressed() -> void:
	get_tree().quit()

"""
@brief Button to toggle the sound
"""
func _on_sound_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		sound_button.texture_normal = load("res://assets/icons/audio_on.png")
		sound_button.texture_hover = load("res://assets/icons/audio_on_white.png")
		sound_button.texture_pressed = load("res://assets/icons/audio_on_.png")
		$AudioStreamPlayer2D.play()
		Globals.sound_enabled = true

	else:
		sound_button.texture_normal = load("res://assets/icons/audio_off.png")
		sound_button.texture_hover = load("res://assets/icons/audio_off_white.png")
		sound_button.texture_pressed = load("res://assets/icons/audio_off_.png")
		$AudioStreamPlayer2D.stop()
		Globals.sound_enabled = false
