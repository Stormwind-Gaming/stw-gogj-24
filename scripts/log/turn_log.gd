extends ObjectWithCleanup

class_name TurnLog

var poi: PointOfInterest
var agents: Array[Character]
var log_message: String = ""
var log_type: Enums.LogType

func _init(message: String, type: Enums.LogType, poi_attr: PointOfInterest = null, agents_attr: Array[Character] = []) -> void:
	LogDuck.d("Creating new turn log", {
		"message": message,
		"type": type,
		"poi": poi_attr.poi_name if poi_attr else "None",
		"agents": agents_attr.map(func(a): return a.get_full_name()) if agents_attr else []
	})
	
	poi = poi_attr
	agents = agents_attr
	log_message = message
	log_type = type

	EventBus.log_created.emit(self)
	LogDuck.d("Turn log created and emitted")
