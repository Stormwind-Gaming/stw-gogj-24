extends Object

class_name TurnLog

var log_message: String = ""
var log_type: Enums.LogType

func _init(message: String, type: Enums.LogType):
	log_message = message
	log_type = type

	EventBus.emit_signal("log_created", self)
