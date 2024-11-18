extends Object

class_name TurnLog

var poi: PointOfInterest
var agents: Array[Character]
var log_message: String = ""
var log_type: Enums.LogType
var event_type: Enums.EventOutcomeType

func _init(message: String, type: Enums.LogType, event_type_attr: Enums.EventOutcomeType = Enums.EventOutcomeType.NONE, poi_attr: PointOfInterest = null, agents_attr: Array[Character] = []) -> void:
	poi = poi_attr
	agents = agents_attr
	log_message = message
	log_type = type
	event_type = event_type_attr

	EventBus.emit_signal("log_created", self)
