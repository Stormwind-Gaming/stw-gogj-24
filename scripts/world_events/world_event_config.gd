extends Object

class_name WorldEventConfig

var event_severity: Enums.WorldEventSeverity
var event_type: Enums.WorldEventType
var event_title: String
var event_text: String
var event_end_text: String
var effect_text: String
var event_button_text: String

func _init(config: Dictionary) -> void:
	LogDuck.d("Initializing world event config", {"config": config})
	
	event_severity = config["event_severity"]
	event_type = config["event_type"]
	event_title = config["event_title"]
	event_text = config["event_text"]
	event_end_text = config["event_end_text"]
	effect_text = config["effect_text"]
	event_button_text = config["event_button_text"]
	
	LogDuck.d("World event config initialized", {
		"severity": event_severity,
		"type": event_type,
		"title": event_title,
		"text": event_text,
		"end_text": event_end_text,
		"effect": effect_text,
		"button_text": event_button_text
	})
