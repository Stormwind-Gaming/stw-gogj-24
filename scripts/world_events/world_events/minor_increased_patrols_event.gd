extends WorldEvent

class_name MinorIncreasedPatrolsEvent

var subject_district: District

func _init(config: WorldEventConfig) -> void:
	LogDuck.d("Initializing minor increased patrols event")

	turn_to_end = GameController.turn_number + 5
	subject_district = GlobalRegistry.districts.get_random_item()

	LogDuck.d("Minor increased patrols event setup", {
		"turn_to_end": turn_to_end,
		"district": subject_district.district_name
	})

	config.event_text = config.event_text.replace("{district}", subject_district.district_name)
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	LogDuck.d("Event text configured", {
		"event_text": config.event_text,
		"end_text": event_end_text,
		"effect_text": effect_text
	})

	super(config.event_severity)

func _event_start() -> void:
	LogDuck.d("Starting minor increased patrols event")
	
	LogDuck.d("Applying district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": Constants.WORLD_EVENT_MINOR_INCREASED_PATROLS_HEAT_CHANGE
	})
	subject_district.heat += Constants.WORLD_EVENT_MINOR_INCREASED_PATROLS_HEAT_CHANGE

func _event_end() -> void:
	LogDuck.d("Ending minor increased patrols event")
	
	LogDuck.d("Removing district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": - Constants.WORLD_EVENT_MINOR_INCREASED_PATROLS_HEAT_CHANGE
	})
	subject_district.heat -= Constants.WORLD_EVENT_MINOR_INCREASED_PATROLS_HEAT_CHANGE
	queue_free()
