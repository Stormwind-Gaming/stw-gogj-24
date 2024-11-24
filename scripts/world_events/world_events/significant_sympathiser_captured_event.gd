extends WorldEvent

class_name SignificantSympathiserCapturedEvent

var subject_character: Character
var subject_district: District

func _init(config: WorldEventConfig) -> void:
	print("initialising significant sympathiser captured event")

	turn_to_end = GameController.turn_number + Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_DURATION
	var subject_characters = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_NOT_RECRUITED) + GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED)
	subject_character = subject_characters[randi() % subject_characters.size()]
	subject_district = GlobalRegistry.districts.find_item(GlobalRegistry.LIST_ALL_DISTRICTS, "district_type", Enums.DistrictType.CIVIC)

	# setup
	config.event_text = config.event_text.replace("{character}", subject_character.get_full_name())
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	super(config.event_severity)


func _event_start() -> void:
	print("--- Starting significant sympathiser captured event ---")
	print("Subject character: ", subject_character.get_full_name(), "Sympathy: ", subject_character.char_sympathy, " + ", Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_SYMPATHY_CHANGE)
	subject_character.char_sympathy += Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_SYMPATHY_CHANGE

	# TODO: Add 5 turns of injury to character

	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " + ", Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_HEAT_CHANGE)
	subject_district.heat += Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_HEAT_CHANGE

	pass

func _event_end() -> void:
	print("--- Ending significant sympathiser captured event ---")
	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " - ", Constants.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED_HEAT_CHANGE)
	subject_district.heat -= Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE
	queue_free()
	pass
