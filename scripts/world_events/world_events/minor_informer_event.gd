extends WorldEvent

class_name MinorInformerEvent

var subject_character: Character

func _init(config: WorldEventConfig) -> void:
	LogDuck.d("Initializing minor informer event")

	turn_to_end = GameController.turn_number + 1
	var subject_characters = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_NON_SYMPATHISER_UNKNOWN) + GlobalRegistry.characters.get_list(GlobalRegistry.LIST_NON_SYMPATHISER_KNOWN) + GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_NOT_RECRUITED) + GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED)
	subject_character = subject_characters[randi() % subject_characters.size()]

	LogDuck.d("Minor informer event setup", {
		"turn_to_end": turn_to_end,
		"character": subject_character.get_full_name(),
		"current_sympathy": subject_character.char_sympathy
	})

	# setup
	config.event_text = config.event_text.replace("{character}", subject_character.get_full_name())
	event_text = config.event_text

	config.event_end_text = config.event_end_text.replace("{character}", subject_character.get_full_name())
	event_end_text = config.event_end_text

	config.effect_text = config.effect_text.replace("{character}", subject_character.get_full_name())
	effect_text = config.effect_text

	LogDuck.d("Event text configured", {
		"event_text": config.event_text,
		"end_text": event_end_text,
		"effect_text": effect_text
	})

	super(config.event_severity)

func _event_start() -> void:
	LogDuck.d("Starting minor informer event")
	
	LogDuck.d("Modifying character sympathy", {
		"character": subject_character.get_full_name(),
		"current_sympathy": subject_character.char_sympathy,
		"change": Constants.WORLD_EVENT_MINOR_INFORMER_SYMPATHY_CHANGE
	})
	
	subject_character.char_sympathy += Constants.WORLD_EVENT_MINOR_INFORMER_SYMPATHY_CHANGE

func _event_end() -> void:
	LogDuck.d("Ending minor informer event", {
		"character": subject_character.get_full_name(),
		"final_sympathy": subject_character.char_sympathy
	})
	queue_free()
