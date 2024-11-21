extends WorldEvent

class_name MinorIncreasedPatrolsEvent

var subject_district: District

func _init(config: WorldEventConfig) -> void:
	print("Initialising minor increased patrols event")

	turn_to_end = GameController.turn_number + 5
	subject_district = GlobalRegistry.districts.get_random_item()

	event_text = config.event_text.replace("{district}", subject_district.district_name)
	event_end_text = config.event_end_text
	effect_text = config.effect_text


	super(config.event_severity)


func _event_start() -> void:
	print("--- Starting minor increased patrols event ---")
	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " + ", Constants.WORLD_EVENT_MINOR_INCREASED_PATROLS_HEAT_CHANGE)
	subject_district.heat += Constants.WORLD_EVENT_MINOR_INCREASED_PATROLS_HEAT_CHANGE

func _event_end() -> void:
	print("--- Ending minor increased patrols event ---")
	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " - ", Constants.WORLD_EVENT_MINOR_INCREASED_PATROLS_HEAT_CHANGE)
	subject_district.heat -= Constants.WORLD_EVENT_MINOR_INCREASED_PATROLS_HEAT_CHANGE
