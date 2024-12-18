extends WorldEvent

class_name SignificantSympathiserCapturedEvent

var subject_character: Character
var subject_district: District

func _init(config: WorldEventConfig) -> void:
	LogDuck.d("Initializing significant sympathiser captured event")

	turn_to_end = ReferenceGetter.game_controller().turn_number + Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_DURATION
	var subject_characters = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_SYMPATHISER_NOT_RECRUITED) + ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_SYMPATHISER_RECRUITED)
	#	filter out any characters that are injured
	subject_characters = subject_characters.filter(func(c): return c.char_state != Enums.CharacterState.INJURED)
	if subject_characters.size() == 0:
		LogDuck.e("No available characters for significant sympathiser captured event")
		failed_to_init = true
		return

	subject_character = subject_characters[randi() % subject_characters.size()]
	subject_district = ReferenceGetter.global_registry().districts.find_item(ReferenceGetter.global_registry().LIST_ALL_DISTRICTS, "district_type", Enums.DistrictType.CIVIC)

	LogDuck.d("Significant sympathiser captured event setup", {
		"turn_to_end": turn_to_end,
		"character": subject_character.get_full_name(),
		"district": subject_district.district_name
	})

	# setup
	config.event_text = config.event_text.replace("{character}", subject_character.get_full_name()).replace("{district}", subject_district.district_name)
	event_text = config.event_text

	config.event_end_text = config.event_end_text.replace("{character}", subject_character.get_full_name()).replace("{district}", subject_district.district_name)
	event_end_text = config.event_end_text

	config.effect_text = config.effect_text.replace("{character}", subject_character.get_full_name()).replace("{district}", subject_district.district_name)
	effect_text = config.effect_text

	LogDuck.d("Event text configured", {
		"event_text": config.event_text,
		"end_text": event_end_text,
		"effect_text": effect_text
	})

	super(config.event_severity)

func _event_start() -> void:
	LogDuck.d("Starting significant sympathiser captured event")
	
	LogDuck.d("Setting character to injured state", {
		"character": subject_character.get_full_name(),
		"previous_state": subject_character.char_state,
		"return_turn": ReferenceGetter.game_controller().turn_number + Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_DURATION
	})
	subject_character.set_char_state(Enums.CharacterState.INJURED)
	subject_character.injured_return_on_turn = ReferenceGetter.game_controller().turn_number + Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_DURATION

	LogDuck.d("Modifying character sympathy", {
		"character": subject_character.get_full_name(),
		"current_sympathy": subject_character.char_sympathy,
		"change": Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_SYMPATHY_CHANGE
	})
	subject_character.char_sympathy += Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_SYMPATHY_CHANGE

	LogDuck.d("Applying district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_HEAT_CHANGE
	})
	subject_district.heat += Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_HEAT_CHANGE

func _event_end() -> void:
	LogDuck.d("Ending significant sympathiser captured event")
	
	LogDuck.d("Removing district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": - Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_HEAT_CHANGE
	})
	subject_district.heat -= Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE
	queue_free()
