extends WorldEvent

class_name MajorSafehouseDiscoveredEvent

var subject_district: District
var subject_characters: Array[Character]

func _init(config: WorldEventConfig) -> void:
	print("initialising major safehouse discovered event")

	turn_to_end = GameController.turn_number + Constants.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED_DURATION
	subject_district = GlobalRegistry.districts.get_random_item()

	# setup
	event_text = config.event_text.replace("{district}", subject_district.district_name)
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	super(config.event_severity)


func _event_start() -> void:
	print("--- Starting major safehouse discovered event ---")

	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " + ", Constants.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED_HEAT_CHANGE)
	subject_district.heat += Constants.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED_HEAT_CHANGE

	# Find all characters in the district
	var all_sympathisers = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_NOT_RECRUITED) + GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED)
	subject_characters = all_sympathisers.filter(
		func(character): character.char_associated_poi.parent_district == subject_district
	)

	# set all characters to MIA 
	for character in subject_characters:
		character.set_char_state(Enums.CharacterState.MIA)

	pass

func _event_end() -> void:
	print("--- Ending major safehouse discovered event ---")
	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " - ", Constants.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED_HEAT_CHANGE)
	subject_district.heat -= Constants.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED_HEAT_CHANGE

	# set all characters to available
	for character in subject_characters:
		character.set_char_state(Enums.CharacterState.AVAILABLE)
	
	queue_free()
	pass
