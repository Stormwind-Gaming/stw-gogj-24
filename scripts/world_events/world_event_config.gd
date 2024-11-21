extends Object

class_name WorldEventConfig

var event_severity: Enums.WorldEventSeverity
var event_type: Enums.WorldEventType
var event_text: String
var event_end_text: String
var effect_text: String

func _init(config: Dictionary) -> void:
	event_severity = config["event_severity"]
	event_type = config["event_type"]
	event_text = config["event_text"]
	event_end_text = config["event_end_text"]
	effect_text = config["effect_text"]
