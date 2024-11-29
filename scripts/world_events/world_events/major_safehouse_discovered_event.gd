extends WorldEvent

class_name MajorSafehouseDiscoveredEvent

var subject_district: District
var subject_characters: Array

func _init(config: WorldEventConfig) -> void:
	LogDuck.d("Initializing major safehouse discovered event")

	turn_to_end = ReferenceGetter.game_controller().turn_number + Constants.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED_DURATION
	subject_district = ReferenceGetter.global_registry().districts.get_random_item()

	LogDuck.d("Major safehouse event setup", {
		"turn_to_end": turn_to_end,
		"district": subject_district.district_name
	})

	# setup
	config.event_text = config.event_text.replace("{district}", subject_district.district_name)
	event_text = config.event_button_text

	config.effect_text = config.effect_text.replace("{district}", subject_district.district_name)
	effect_text = config.effect_text

	config.event_end_text = config.event_end_text.replace("{district}", subject_district.district_name)
	event_end_text = config.event_end_text

	LogDuck.d("Event text configured", {
		"event_text": event_text,
		"end_text": event_end_text,
		"effect_text": effect_text
	})

	super(config.event_severity)

func _event_start() -> void:
	LogDuck.d("Starting major safehouse discovered event")

	LogDuck.d("Applying district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": Constants.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED_HEAT_CHANGE
	})
	subject_district.heat += Constants.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED_HEAT_CHANGE

	# Find all characters in the district
	var all_sympathisers = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_SYMPATHISER_NOT_RECRUITED) + ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_SYMPATHISER_RECRUITED)
	subject_characters = all_sympathisers.filter(
		func(character): character.char_associated_poi.parent_district == subject_district
	)

	LogDuck.d("Found affected characters", {
		"character_count": subject_characters.size(),
		"district": subject_district.district_name
	})

	# set all characters to MIA 
	for character in subject_characters:
		LogDuck.d("Setting character to MIA", {
			"character": character.char_name,
			"previous_state": character.char_state
		})
		character.set_char_state(Enums.CharacterState.MIA)

func _event_end() -> void:
	LogDuck.d("Ending major safehouse discovered event")
	
	LogDuck.d("Removing district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": - Constants.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED_HEAT_CHANGE
	})
	subject_district.heat -= Constants.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED_HEAT_CHANGE

	# set all characters to available
	for character in subject_characters:
		if character.char_state == Enums.CharacterState.MIA:
			LogDuck.d("Restoring character from MIA", {
				"character": character.char_name,
				"current_state": character.char_state
			})
			character.set_char_state(Enums.CharacterState.AVAILABLE)
	
	queue_free()
