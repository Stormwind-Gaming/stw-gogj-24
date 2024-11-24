extends WorldEvent

class_name SignificantWeaponsCacheEvent

var subject_district: District

func _init(config: WorldEventConfig) -> void:
	print("initialising significant weapons cache event")

	turn_to_end = GameController.turn_number + Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_DURATION
	subject_district = GlobalRegistry.districts.get_random_item()

	# setup
	event_text = config.event_text.replace("{district}", subject_district.district_name)
	event_end_text = config.event_end_text
	effect_text = config.effect_text

	super(config.event_severity)


func _event_start() -> void:
	print("--- Starting significant weapons cache event ---")
	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " + ", Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_HEAT_CHANGE)
	subject_district.heat += Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_HEAT_CHANGE

	# reduce all Intel (rumours) time remaining by 3 turns
	for rumour in GlobalRegistry.intel.get_list(GlobalRegistry.LIST_RUMOURS):
		rumour.turns_remaining -= Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_RUMOUR_DURATION_REDUCTION
		# if the rumour has expired, remove it
		if rumour.turns_remaining <= 0:
			print("Removing expired rumour: ", rumour.rumour_text)
			GlobalRegistry.intel.remove_item(rumour)
			rumour.queue_free()

	pass

func _event_end() -> void:
	print("--- Ending significant weapons cache event ---")
	print("Subject district: ", subject_district.district_name, "Heat: ", subject_district.heat, " - ", Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_HEAT_CHANGE)
	subject_district.heat -= Constants.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE_HEAT_CHANGE
	queue_free()
	pass
