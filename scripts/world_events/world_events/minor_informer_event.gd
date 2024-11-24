extends WorldEvent

class_name MinorInformerEvent

var subject_character: Character

func _init(config: WorldEventConfig) -> void:
	print("initialising minor informer event")

	turn_to_end = GameController.turn_number + 1
	var subject_characters = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_NON_SYMPATHISER_UNKNOWN) + GlobalRegistry.characters.get_list(GlobalRegistry.LIST_NON_SYMPATHISER_KNOWN) + GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_NOT_RECRUITED) + GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED)
	subject_character = subject_characters[randi() % subject_characters.size()]

	# setup
	config.event_text = config.event_text.replace("{character}", subject_character.get_full_name())
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	super(config.event_severity)


func _event_start() -> void:
	print("--- Starting minor informer event ---")
	print("Subject character: ", subject_character.get_full_name(), "Sympathy: ", subject_character.char_sympathy, " + ", Constants.WORLD_EVENT_MINOR_INFORMER_SYMPATHY_CHANGE)
	
	subject_character.char_sympathy += Constants.WORLD_EVENT_MINOR_INFORMER_SYMPATHY_CHANGE
	pass

func _event_end() -> void:
	print("--- Ending minor informer event ---")
	queue_free()
	pass
