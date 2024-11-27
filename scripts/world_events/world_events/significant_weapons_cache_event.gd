extends WorldEvent

class_name SignificantWeaponsCacheEvent

var subject_district: District

func _init(config: WorldEventConfig) -> void:
	LogDuck.d("Initializing significant weapons cache event")

	turn_to_end = GameController.turn_number + Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_DURATION
	subject_district = GlobalRegistry.districts.get_random_item()

	LogDuck.d("Significant weapons cache event setup", {
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
		"event_text": event_text,
		"end_text": event_end_text,
		"effect_text": effect_text
	})

	super(config.event_severity)

func _event_start() -> void:
	LogDuck.d("Starting significant weapons cache event")
	
	LogDuck.d("Applying district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_HEAT_CHANGE
	})
	subject_district.heat += Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_HEAT_CHANGE

	LogDuck.d("Processing rumours for duration reduction", {
		"reduction": Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_RUMOUR_DURATION_REDUCTION
	})
	
	# reduce all Intel (rumours) time remaining by 3 turns
	var rumour_count = 0
	var expired_count = 0
	for rumour in GlobalRegistry.intel.get_list(GlobalRegistry.LIST_RUMOURS):
		rumour.rumour_subject_expiry -= Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_RUMOUR_DURATION_REDUCTION
		rumour_count += 1
		
		# if the rumour has expired, remove it
		if rumour.rumour_subject_expiry <= 0:
			LogDuck.d("Removing expired rumour", {
				"rumour_text": rumour.rumour_text,
				"previous_turns": rumour.rumour_subject_expiry + Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_RUMOUR_DURATION_REDUCTION
			})
			GlobalRegistry.intel.remove_item(rumour)
			rumour.queue_free()
			expired_count += 1

	LogDuck.d("Finished processing rumours", {
		"total_rumours": rumour_count,
		"expired_rumours": expired_count
	})

func _event_end() -> void:
	LogDuck.d("Ending significant weapons cache event")
	
	LogDuck.d("Removing district heat change", {
		"district": subject_district.district_name,
		"current_heat": subject_district.heat,
		"change": - Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_HEAT_CHANGE
	})
	subject_district.heat -= Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_HEAT_CHANGE
	queue_free()
