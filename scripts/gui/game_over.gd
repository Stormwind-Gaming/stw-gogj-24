extends Control

#|==============================|
#|        Lifecycle methods     |
#|==============================|
"""
@brief Called when the node enters the scene tree for the first time
"""
func _ready() -> void:
	print("Game Over Screen Ready")
	$AnimationPlayer.play("fade_in")


#|==============================|
#|        Signal Callbacks      |
#|==============================|
"""
@brief Called when the quit to menu button is pressed
"""
func _on_quit_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")