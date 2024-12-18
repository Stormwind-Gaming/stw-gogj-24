extends WorldEvent

class_name MajorPoliceCommanderEvent

var subject_districts: Array
var subject_district_civic: District

func _init(config: WorldEventConfig) -> void:
	LogDuck.d("Initializing major police commander event")

	turn_to_end = ReferenceGetter.game_controller().turn_number + Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_DURATION
	subject_districts = ReferenceGetter.global_registry().districts.get_list(ReferenceGetter.global_registry().LIST_ALL_DISTRICTS)
	subject_district_civic = ReferenceGetter.global_registry().districts.find_item(ReferenceGetter.global_registry().LIST_ALL_DISTRICTS, "district_type", Enums.DistrictType.CIVIC)

	LogDuck.d("Major police commander event setup", {
		"turn_to_end": turn_to_end,
		"civic_district": subject_district_civic.district_name,
		"district_count": subject_districts.size()
	})

	# setup
	config.event_end_text = config.event_end_text.replace("{district}", subject_district_civic.district_name)
	event_end_text = config.event_end_text

	config.effect_text = config.effect_text.replace("{district}", subject_district_civic.district_name)
	effect_text = config.effect_text

	config.event_text = config.event_text.replace("{district}", subject_district_civic.district_name)
	event_text = config.event_text

	super(config.event_severity)

func _event_start() -> void:
	LogDuck.d("Starting major police commander event")

	LogDuck.d("Applying civic district heat change", {
		"district": subject_district_civic.district_name,
		"current_heat": subject_district_civic.heat,
		"change": Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_CIVIC
	})
	subject_district_civic.heat += Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_CIVIC

	for district in subject_districts:
		LogDuck.d("Applying district heat change", {
			"district": district.district_name,
			"current_heat": district.heat,
			"change": Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_ALL
		})
		district.heat += Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_ALL

func _event_end() -> void:
	LogDuck.d("Ending major police commander event")
	
	LogDuck.d("Removing civic district heat change", {
		"district": subject_district_civic.district_name,
		"current_heat": subject_district_civic.heat,
		"change": - Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_CIVIC
	})
	subject_district_civic.heat -= Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_CIVIC

	for district in subject_districts:
		LogDuck.d("Removing district heat change", {
			"district": district.district_name,
			"current_heat": district.heat,
			"change": - Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_ALL
		})
		district.heat -= Constants.WORLD_EVENT_MAJOR_POLICE_COMMANDER_HEAT_CHANGE_ALL
	
	queue_free()
