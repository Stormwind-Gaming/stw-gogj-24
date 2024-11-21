extends WorldEvent

class_name MinorSecretPoliceEvent

var subject_district: District
var modifier: Modifier = null

func _init(config: WorldEventConfig) -> void:
	print("Initialising minor secret police event")

	turn_to_end = GameController.turn_number + 2
	subject_district = GlobalRegistry.districts.get_random_item()

	event_text = config.event_text.replace("{district}", subject_district.district_name)
	event_end_text = config.event_end_text
	effect_text = config.effect_text


	print("Subject district: ", subject_district.district_name)

	super(config.event_severity)


func _event_start() -> void:
	print("--- Starting minor secret police event ---")
	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " + ", Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE)
	subject_district.heat += Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE

	modifier = Modifier.new({
		"scope": Enums.ModifierScope.DISTRICT,
		"district": subject_district,
		"modifier_name": "Minor Secret Police Event" # TODO: Add event name
	}, {
		"modifier_mission_duration_flat": Constants.WORLD_EVENT_MINOR_SECRET_POLICE_ACTION_DURATION
	})

func _event_end() -> void:
	print("--- Ending minor secret police event ---")
	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " - ", Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE)
	subject_district.heat -= Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE
	modifier.queue_free()
	queue_free()
