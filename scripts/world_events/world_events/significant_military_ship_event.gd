extends WorldEvent

class_name SignificantMilitaryShipEvent

var subject_district: District
var modifier: Modifier = null

func _init(config: WorldEventConfig) -> void:
	LogDuck.d("Initializing significant military ship event")

	turn_to_end = GameController.turn_number + Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_DURATION
	subject_district = GlobalRegistry.districts.find_item(GlobalRegistry.LIST_ALL_DISTRICTS, "district_type", Enums.DistrictType.PORT)

	LogDuck.d("Significant military ship event setup", {
		"turn_to_end": turn_to_end,
		"district": subject_district.district_name
	})

	# setup
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	LogDuck.d("Event text configured", {
		"end_text": event_end_text,
		"effect_text": effect_text
	})

	super(config.event_severity)

func _event_start() -> void:
	LogDuck.d("Starting significant military ship event")
	
	LogDuck.d("Applying district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_HEAT_CHANGE
	})
	subject_district.heat += Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_HEAT_CHANGE

	LogDuck.d("Creating military ship modifier", {
		"district": subject_district.district_name,
		"intel_spawn_increase": Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_INTEL_SPAWN_INCREASE
	})
	modifier = Modifier.new({
		"scope": Enums.ModifierScope.DISTRICT,
		"district": subject_district,
		"modifier_name": "Significant Military Ship Event" # TODO: Add event name
	}, {
		"modifier_intel_spawn_flat": Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_INTEL_SPAWN_INCREASE
	})

func _event_end() -> void:
	LogDuck.d("Ending significant military ship event")
	
	LogDuck.d("Removing district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": - Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_HEAT_CHANGE
	})
	subject_district.heat -= Constants.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP_HEAT_CHANGE
	
	LogDuck.d("Removing military ship modifier", {
		"district": subject_district.district_name
	})
	modifier.queue_free()
	queue_free()
