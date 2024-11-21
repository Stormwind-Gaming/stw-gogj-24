extends WorldEvent

class_name MinorSecretPoliceEvent

var subject_district: District

func _init(config: WorldEventConfig) -> void:
	print("Initialising minor secret police event")

	event_text = config.event_text
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	turn_to_end = GameController.turn_number + 2
	subject_district = GlobalRegistry.districts.get_random_item()

	super(config.event_severity)


func _event_start() -> void:
	# TODO: Add logic for +1 mission duration
	subject_district.heat += Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE
	pass

func _event_end() -> void:
	# TODO: Add logic for -1 mission duration
	subject_district.heat -= Constants.WORLD_EVENT_MINOR_SECRET_POLICE_HEAT_CHANGE
	pass
