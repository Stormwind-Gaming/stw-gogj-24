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

func _init(init_severity: Enums.WorldEventSeverity) -> void:
	severity = init_severity

	GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), TurnLog.new("A new world event has occurred!", Enums.LogType.WORLD_EVENT))
	EventBus.world_event_created.emit(self)

