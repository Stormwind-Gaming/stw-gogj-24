extends Object

class_name TurnLog

var poi: PointOfInterest
var agents: Array[Character]
var log_message: String = ""
var log_type: Enums.LogType

func _init(message: String, type: Enums.LogType, poi_attr: PointOfInterest = null, agents_attr: Array[Character] = []) -> void:
	poi = poi_attr
	agents = agents_attr
	log_message = message
	log_type = type

	EventBus.log_created.emit(self)
