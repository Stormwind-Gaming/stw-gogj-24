extends Window

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Label that displays the log entries
"""
@export var label: RichTextLabel

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Whether to use typewriter effect for text display
"""
var type_effect: bool = false

"""
@brief Speed of the typewriter effect
"""
var type_effect_speed: float = 0.25

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Connects signals and populates the log with current turn entries.
"""
func _ready():
	# Connect the close_requested signal
	connect("close_requested", Callable(self, "_on_close_requested"))
	
	for line in GameController.get_turn_log(GameController.turn_number):
		label.text += line + "\n"

"""
@brief Called every frame to update typewriter effect if enabled.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	if type_effect:
		label.visible_ratio += delta * type_effect_speed
		if label.visible_ratio >= 1:
			type_effect = false

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Enables the typewriter effect for log display.

@param type_effect_speed Speed of the typewriter effect
@return bool Always returns true
"""
func is_end_turn_log(type_effect_speed: float = 0.25) -> bool:
	type_effect = true
	label.visible_ratio = 0
	self.type_effect_speed = type_effect_speed
	return type_effect

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the close button press.
"""
func _on_close_button_pressed() -> void:
	GameController.set_menu_closed("LogList")
	queue_free()
