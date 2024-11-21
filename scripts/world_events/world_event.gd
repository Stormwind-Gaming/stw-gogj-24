extends Object

class_name WorldEvent

"""
@brief The turn this world-event will end
"""
var turn_to_end: int

"""
@brief The severity of this world-event
"""
var severity: Enums.WorldEventSeverity

"""
@brief The text of this world-event
"""
var event_text: String

"""
@brief The text of this world-event when it ends
"""
var event_end_text: String

"""
@brief The effect text of this world-event
"""
var effect_text: String

func _init(init_severity: Enums.WorldEventSeverity) -> void:

	severity = init_severity

	_event_start()

	GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), TurnLog.new(event_text, Enums.LogType.WORLD_EVENT))
	EventBus.world_event_created.emit(self)

	EventBus.turn_processing_initiated.connect(_on_end_turn)

"""
@brief The function that is called when the world-event starts
"""
func _event_start() -> void:
	pass

"""
@brief The function that is called when the world-event ends
"""
func _event_end() -> void:
	pass

func _on_end_turn(turn_number: int) -> void:
	print("Checking if world-event should end", turn_number, "==", turn_to_end)
	if turn_number == turn_to_end:
		print("World-event ended", event_end_text)
		# TODO: Why is this log not showing?
		GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), TurnLog.new(event_end_text, Enums.LogType.WORLD_EVENT))
		EventBus.world_event_ended.emit(self)
		_event_end()
