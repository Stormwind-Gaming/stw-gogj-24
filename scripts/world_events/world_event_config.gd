extends Object

class_name WorldEventConfig

var event_severity: Enums.WorldEventSeverity
var event_type: Enums.WorldEventType
var event_text: String
var event_end_text: String
var effect_text: String

func _init(config: Dictionary) -> void:
	LogDuck.d("Initializing world event config", {"config": config})
	
	event_severity = config["event_severity"]
	event_type = config["event_type"]
	event_text = config["event_text"]
	event_end_text = config["event_end_text"]
	effect_text = config["effect_text"]
	
	LogDuck.d("World event config initialized", {
		"severity": event_severity,
		"type": event_type,
		"text": event_text,
		"end_text": event_end_text,
		"effect": effect_text
	})
