extends Control

#|==============================|
#|   Exported Properties       |
#|==============================|
"""
@brief Reference to the stats panel
"""
@export var stats_panel: PanelContainer

#|==============================|
#|        Lifecycle methods     |
#|==============================|
"""
@brief Called when the node enters the scene tree for the first time
"""
func _ready() -> void:
	print("Game Over Screen Ready")
	$AnimationPlayer.play("fade_in")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_stats_panel"):
		stats_panel.visible = not stats_panel.visible

#|==============================|
#|        Signal Callbacks      |
#|==============================|
"""
@brief Called when the quit to menu button is pressed
"""
func _on_quit_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
