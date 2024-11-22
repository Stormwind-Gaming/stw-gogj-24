extends PanelContainer


#|==============================|
#|     Exported Properties      |
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

"""
@brief Turn number logs to display
"""
var turn_number: int = 0


#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called every frame to update typewriter effect if enabled.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	if type_effect:
		# label.visible_characters += 1
		# if label.visible_ratio >= 1:
			type_effect = false
	
	# detect left click to end typewriter effect
	if Input.is_action_just_pressed("left_click"):
		type_effect = false
		# label.visible_characters = label.text.length()

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief sets the turn logs to be displayed in the log window.

@param turn_logs Array of TurnLog objects to display
"""
func set_turn_logs(turn_number_attr: int) -> void:
	turn_number = turn_number_attr
	var turn_logs = GlobalRegistry.turn_logs.get_list(str(turn_number))

	self.name = GameController.calendar.get_date_string(turn_number - GameController.turn_number - 1, false)
	
	for turn_log in turn_logs:
		if turn_log.log_type == Enums.LogType.WORLD_INFO:
			label.text += "[color=yellow]" + turn_log.log_message + "[/color]\n"
		elif turn_log.log_type == Enums.LogType.ACTION_INFO:
			label.text += "[color=blue]" + turn_log.log_message + "[/color]\n"
		elif turn_log.log_type == Enums.LogType.CONSEQUENCE:
			label.text += "[color=red]" + turn_log.log_message + "[/color]\n"
		elif turn_log.log_type == Enums.LogType.SUCCESS:
			label.text += "[color=green]" + turn_log.log_message + "[/color]\n"
		elif turn_log.log_type == Enums.LogType.WORLD_EVENT:
			label.text += "[color=purple]" + turn_log.log_message + "[/color]\n"
		else:
			label.text += "[color=grey]" + turn_log.log_message + "[/color]\n"
	
	# if no logs, display message
	if len(turn_logs) == 0:
		label.text = "No logs today."

"""
@brief Enables the typewriter effect for log display.

@param type_effect_speed Speed of the typewriter effect
@return bool Always returns true
"""
func is_end_turn_log(type_effect_speed: float = 0.25) -> bool:
	type_effect = true
	# label.visible_ratio = 0
	# label.visible_characters = 0
	self.type_effect_speed = type_effect_speed
	return type_effect
