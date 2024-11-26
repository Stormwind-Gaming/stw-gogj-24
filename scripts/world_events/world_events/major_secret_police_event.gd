extends WorldEvent

class_name MajorSecretPoliceEvent

var subject_character: Character
var subject_district_civic: District
var subject_district_military: District

func _init(config: WorldEventConfig) -> void:
	LogDuck.d("Initializing major secret police event")

	turn_to_end = GameController.turn_number + Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_DURATION
	var subject_characters = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_NOT_RECRUITED) + GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED)
	subject_character = subject_characters[randi() % subject_characters.size()]
	subject_district_civic = GlobalRegistry.districts.find_item(GlobalRegistry.LIST_ALL_DISTRICTS, "district_type", Enums.DistrictType.CIVIC)
	subject_district_military = GlobalRegistry.districts.find_item(GlobalRegistry.LIST_ALL_DISTRICTS, "district_type", Enums.DistrictType.MILITARY)

	LogDuck.d("Major secret police event setup", {
		"turn_to_end": turn_to_end,
		"character": subject_character.get_full_name(),
		"civic_district": subject_district_civic.district_name,
		"military_district": subject_district_military.district_name
	})

	# setup
	config.event_text = config.event_text.replace("{character}", subject_character.get_full_name())
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	LogDuck.d("Event text configured", {
		"event_text": config.event_text,
		"end_text": event_end_text,
		"effect_text": effect_text
	})

	super(config.event_severity)

func _event_start() -> void:
	LogDuck.d("Starting major secret police event")
	
	LogDuck.d("Modifying character sympathy", {
		"character": subject_character.get_full_name(),
		"current_sympathy": subject_character.char_sympathy,
		"change": Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_SYMPATHY_CHANGE
	})
	subject_character.char_sympathy += Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_SYMPATHY_CHANGE

	LogDuck.d("Setting character to MIA", {
		"character": subject_character.get_full_name(),
		"previous_state": subject_character.char_state
	})
	subject_character.set_char_state(Enums.CharacterState.MIA)

	LogDuck.d("Applying civic district heat change", {
		"district": subject_district_civic.district_name,
		"current_heat": subject_district_civic.heat,
		"change": Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_CIVIC
	})
	subject_district_civic.heat += Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_CIVIC

	LogDuck.d("Applying military district heat change", {
		"district": subject_district_military.district_name,
		"current_heat": subject_district_military.heat,
		"change": Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_MILITARY
	})
	subject_district_military.heat += Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_MILITARY

func _event_end() -> void:
	LogDuck.d("Ending major secret police event")
	
	LogDuck.d("Removing civic district heat change", {
		"district": subject_district_civic.district_name,
		"current_heat": subject_district_civic.heat,
		"change": - Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_CIVIC
	})
	subject_district_civic.heat -= Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_CIVIC

	LogDuck.d("Removing military district heat change", {
		"district": subject_district_military.district_name,
		"current_heat": subject_district_military.heat,
		"change": - Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_MILITARY
	})
	subject_district_military.heat -= Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_MILITARY
	
	queue_free()
