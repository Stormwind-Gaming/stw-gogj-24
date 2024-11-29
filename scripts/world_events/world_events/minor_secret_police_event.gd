extends WorldEvent

class_name MinorSecretPoliceEvent

var subject_district: District
var modifier: Modifier = null

func _init(config: WorldEventConfig) -> void:
	LogDuck.d("Initializing minor secret police event")

	turn_to_end = ReferenceGetter.game_controller().turn_number + 2
	subject_district = ReferenceGetter.global_registry().districts.get_random_item()

	LogDuck.d("Minor secret police event setup", {
		"turn_to_end": turn_to_end,
		"district": subject_district.district_name
	})

	# setup
	config.event_text = config.event_text.replace("{district}", subject_district.district_name)
	event_text = config.event_text

	config.event_end_text = config.event_end_text.replace("{district}", subject_district.district_name)
	event_end_text = config.event_end_text
	
	config.effect_text = config.effect_text.replace("{district}", subject_district.district_name)
	effect_text = config.effect_text

	LogDuck.d("Event text configured", {
		"end_text": event_end_text,
		"effect_text": effect_text
	})

	super(config.event_severity)

func _event_start() -> void:
	LogDuck.d("Starting minor secret police event")
	
	LogDuck.d("Applying district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE
	})
	subject_district.heat += Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE

	LogDuck.d("Creating secret police modifier", {
		"district": subject_district.district_name,
		"action_duration": Constants.WORLD_EVENT_MINOR_SECRET_POLICE_ACTION_DURATION
	})
	modifier = Modifier.new({
		"scope": Enums.ModifierScope.DISTRICT,
		"district": subject_district,
		"modifier_name": "Minor Secret Police Event" # TODO: Add event name
	}, {
		"modifier_mission_duration_flat": Constants.WORLD_EVENT_MINOR_SECRET_POLICE_ACTION_DURATION
	})

func _event_end() -> void:
	LogDuck.d("Ending minor secret police event")
	
	LogDuck.d("Removing district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": - Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE
	})
	subject_district.heat -= Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE
	
	LogDuck.d("Removing secret police modifier", {
		"district": subject_district.district_name
	})
	modifier.queue_free()
	queue_free()
