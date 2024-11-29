extends NodeWithCleanup

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
@brief The data of this world-event
"""
var event_data: WorldEventConfig

"""
@brief The text of this world-event
"""
var event_text: String

"""
@brief The affected character of this world-event
"""
var event_character: Character

"""
@brief The affected district of this world-event
"""
var event_district: District

"""
@brief The affected poi of this world-event
"""
var event_poi: PointOfInterest

"""
@brief The text of this world-event when it ends
"""
var event_end_text: String

"""
@brief The effect text of this world-event
"""
var effect_text: String

"""
@brief Stopper for if this world event failed to initialize 
"""
var failed_to_init: bool = false


func _init(init_severity: Enums.WorldEventSeverity) -> void:
	LogDuck.d("Initializing world event", {"severity": init_severity})
	severity = init_severity

	_event_start()

	LogDuck.d("World event initialized", {
		"text": event_text,
		"turn": ReferenceGetter.game_controller().turn_number,
		"severity": severity
	})

	EventBus.turn_processing_initiated.connect(_on_end_turn)

"""
@brief The function that is called when the world-event starts
"""
func _event_start() -> void:
	LogDuck.d("Starting world event base implementation")
	pass

"""
@brief The function that is called when the world-event ends
"""
func _event_end() -> void:
	LogDuck.d("Ending world event base implementation")
	pass

func _on_end_turn(turn_number: int) -> void:
	LogDuck.d("Checking world event end condition", {
		"current_turn": turn_number,
		"end_turn": turn_to_end
	})
	
	if turn_number == turn_to_end:
		LogDuck.d("World event ending", {
			"event_end_text": event_end_text,
			"turn": ReferenceGetter.game_controller().turn_number
		})

		if event_data.event_end_text != "":
			ReferenceGetter.global_registry().turn_logs.add_item(str(ReferenceGetter.game_controller().turn_number), TurnLog.new(event_data.event_end_text, Enums.LogType.WORLD_EVENT))
		
		EventBus.world_event_ended.emit(self)
		_event_end()
