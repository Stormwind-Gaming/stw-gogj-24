extends WorldEvent

class_name MajorSecretPoliceEvent

var subject_character: Character
var subject_district_civic: District
var subject_district_military: District

func _init(config: WorldEventConfig) -> void:
	print("initialising major secret police event")

	turn_to_end = GameController.turn_number + Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_DURATION
	var subject_characters = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_NOT_RECRUITED) + GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED)
	subject_character = subject_characters[randi() % subject_characters.size()]
	subject_district_civic = GlobalRegistry.districts.find_item(GlobalRegistry.LIST_ALL_DISTRICTS, "district_type", Enums.DistrictType.CIVIC)
	subject_district_military = GlobalRegistry.districts.find_item(GlobalRegistry.LIST_ALL_DISTRICTS, "district_type", Enums.DistrictType.MILITARY)

	# setup
	config.event_text = config.event_text.replace("{character}", subject_character.get_full_name())
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	super(config.event_severity)


func _event_start() -> void:
	print("--- Starting major secret police event ---")
	print("Subject character: ", subject_character.get_full_name(), "Sympathy: ", subject_character.char_sympathy, " + ", Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_SYMPATHY_CHANGE)
	subject_character.char_sympathy += Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_SYMPATHY_CHANGE

	subject_character.set_char_state(Enums.CharacterState.MIA)

	print("Subject district: ", subject_district_civic.district_name, "Heat: ", subject_district_civic.heat, " + ", Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_CIVIC)
	subject_district_civic.heat += Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_CIVIC

	print("Subject district: ", subject_district_military.district_name, "Heat: ", subject_district_military.heat, " + ", Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_MILITARY)
	subject_district_military.heat += Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_MILITARY

	pass

func _event_end() -> void:
	print("--- Ending major secret police event ---")
	print("Subject district: ", subject_district_civic.district_name, "Heat: ", subject_district_civic.heat, " - ", Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_CIVIC)
	subject_district_civic.heat -= Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_CIVIC

	print("Subject district: ", subject_district_military.district_name, "Heat: ", subject_district_military.heat, " - ", Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_MILITARY)
	subject_district_military.heat -= Constants.WORLD_EVENT_MAJOR_SECRET_POLICE_HEAT_CHANGE_MILITARY
	
	queue_free()
	pass
