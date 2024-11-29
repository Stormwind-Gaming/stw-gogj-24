extends Control

@export var screen_one: Control
@export var screen_two: Control
@export var screen_three: Control
@export var screen_four: Control
@export var screen_five: Control
@export var screen_six: Control
@export var screen_seven: Control
@export var screen_eight: Control
@export var screen_nine: Control

@export var button_next: TextureButton
@export var button_previous: TextureButton

var current_screen: int = 0

func _ready() -> void:
	current_screen = 0
	button_previous.visible = false
	screen_one.visible = true
	screen_two.visible = false
	screen_three.visible = false
	screen_four.visible = false
	screen_five.visible = false
	screen_six.visible = false
	screen_seven.visible = false
	screen_eight.visible = false
	screen_nine.visible = false

func _on_next_button_pressed() -> void:
	match current_screen:
		0:
			screen_one.visible = false
			screen_two.visible = true
			button_previous.visible = true
		1:
			screen_two.visible = false
			screen_three.visible = true
		2:
			screen_three.visible = false
			screen_four.visible = true
		3:
			screen_four.visible = false
			screen_five.visible = true
		4:
			screen_five.visible = false
			screen_six.visible = true
		5:
			screen_six.visible = false
			screen_seven.visible = true
		6:
			screen_seven.visible = false
			screen_eight.visible = true
		7:
			screen_eight.visible = false
			screen_nine.visible = true
		_:
			get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
	
	current_screen += 1

func _on_previous_button_pressed() -> void:
	match current_screen:
		1:
			screen_two.visible = false
			screen_one.visible = true
			button_previous.visible = false
		2:
			screen_three.visible = false
			screen_two.visible = true
		3:
			screen_four.visible = false
			screen_three.visible = true
		4:
			screen_five.visible = false
			screen_four.visible = true
		5:
			screen_six.visible = false
			screen_five.visible = true
		6:
			screen_seven.visible = false
			screen_six.visible = true
		7:
			screen_eight.visible = false
			screen_seven.visible = true
		8:
			screen_nine.visible = false
			screen_eight.visible = true
		_:
			pass

	current_screen -= 1
	if current_screen < 0:
		current_screen = 0
	
