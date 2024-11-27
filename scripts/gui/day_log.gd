extends PanelContainer


var log_item_scene = preload("res://scenes/gui/menus/log_item.tscn")

#|==============================|
#|     Exported Properties      |
#|==============================|
"""
@brief Label that displays the log entries
"""
# @export var label: RichTextLabel
@export var world_container: Container
@export var action_container: Container

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
		var log_item = log_item_scene.instantiate()
		log_item.log_type = turn_log.log_type
		log_item.log_message = turn_log.log_message

		match turn_log.log_type:
			Enums.LogType.WORLD_INFO, Enums.LogType.WORLD_EVENT:
				world_container.add_child(log_item)
			Enums.LogType.ACTION_INFO:
				# if this is the first child, dont add a separator
				if action_container.get_child_count() > 0:
					action_container.add_child(HSeparator.new())
				action_container.add_child(log_item)
			Enums.LogType.CONSEQUENCE, Enums.LogType.SUCCESS:
				action_container.add_child(log_item)
			_:
				pass		
	
	# if no logs, display message
	# if len(turn_logs) == 0:
	# 	label.text = "No logs today."

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
