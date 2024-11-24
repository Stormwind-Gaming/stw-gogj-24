extends WorldEvent

class_name SignificantMilitaryShipEvent

var subject_district: District
var modifier: Modifier = null

func _init(config: WorldEventConfig) -> void:
	print("initialising significant military ship event")

	turn_to_end = GameController.turn_number + Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_DURATION
	subject_district = GlobalRegistry.districts.find_item(GlobalRegistry.LIST_ALL_DISTRICTS, "district_type", Enums.DistrictType.PORT)

	# setup
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	super(config.event_severity)


func _event_start() -> void:
	print("--- Starting significant military ship event ---")
	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " + ", Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_HEAT_CHANGE)
	subject_district.heat += Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_HEAT_CHANGE

	modifier = Modifier.new({
		"scope": Enums.ModifierScope.DISTRICT,
		"district": subject_district,
		"modifier_name": "Significant Military Ship Event" # TODO: Add event name
	}, {
		"modifier_intel_spawn_flat": Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_INTEL_SPAWN_INCREASE
	})

	pass

func _event_end() -> void:
	print("--- Ending significant military ship event ---")
	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " - ", Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_HEAT_CHANGE)
	subject_district.heat -= Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_HEAT_CHANGE
	modifier.queue_free()
	queue_free()
	pass
