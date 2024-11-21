extends WorldEvent

class_name MinorIncreasedPatrolsEvent

var subject_district: District

func _init(config: WorldEventConfig) -> void:
	print("Initialising minor increased patrols event")

	event_text = config.event_text
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	turn_to_end = GameController.turn_number + 5
	subject_district = GlobalRegistry.districts.get_random_item()

	super(config.event_severity)


func _event_start() -> void:
	subject_district.heat += Constants.WORLD_EVENT_MINOR_INCREASED_PATROLS_HEAT_CHANGE

func _event_end() -> void:
	subject_district.heat -= Constants.WORLD_EVENT_MINOR_INCREASED_PATROLS_HEAT_CHANGE
