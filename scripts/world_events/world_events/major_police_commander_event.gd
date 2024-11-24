extends WorldEvent

class_name MajorPoliceCommanderEvent

var subject_districts: Array[District]
var subject_district_civic: District

func _init(config: WorldEventConfig) -> void:
	print("initialising major police commander event")

	turn_to_end = GameController.turn_number + Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_DURATION
	subject_districts = GlobalRegistry.get_list(GlobalRegistry.LIST_ALL_DISTRICTS)
	subject_district_civic = GlobalRegistry.districts.find_item(GlobalRegistry.LIST_ALL_DISTRICTS, "district_type", Enums.DistrictType.CIVIC)

	# setup
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	super(config.event_severity)


func _event_start() -> void:
	print("--- Starting major police commander event ---")

	print("Subject district: ", subject_district_civic.district_name, "Heat: ", subject_district_civic.heat, " + ", Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_CIVIC)
	subject_district_civic.heat += Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_CIVIC

	for district in subject_districts:
		print("Subject district: ", district.district_name, "Heat: ", district.heat, " + ", Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_ALL)
		district.heat += Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_ALL

	pass

func _event_end() -> void:
	print("--- Ending major police commander event ---")
	print("Subject district: ", subject_district_civic.district_name, "Heat: ", subject_district_civic.heat, " - ", Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_CIVIC)
	subject_district_civic.heat -= Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_CIVIC

	for district in subject_districts:
		print("Subject district: ", district.district_name, "Heat: ", district.heat, " - ", Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_ALL)
		district.heat -= Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_ALL
	
	queue_free()
	pass
