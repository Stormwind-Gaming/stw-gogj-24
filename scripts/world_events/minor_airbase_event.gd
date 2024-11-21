extends WorldEvent

class_name MinorAirbaseEvent

var subject_district: District

func _init(config: WorldEventConfig) -> void:
	print("initialising minor airbase event")

	# setup
	event_text = config.event_text
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	turn_to_end = GameController.turn_number + 7
	subject_district = GlobalRegistry.districts.get_random_item()

	super(config.event_severity)


func _event_start() -> void:
	subject_district.heat += Constants.WORLD_EVENT_MINOR_AIRBASE_HEAT_CHANGE
	pass

func _event_end() -> void:
	subject_district.heat -= Constants.WORLD_EVENT_MINOR_AIRBASE_HEAT_CHANGE
	pass
