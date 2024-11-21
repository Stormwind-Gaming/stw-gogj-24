extends BaseAction

class_name PropagandaAction


func _process_action() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	logs.append(TurnLog.new("Processing PROPAGANDA action at [u]" + str(poi.poi_name) + "[/u] by " + _get_character_names(), Enums.LogType.ACTION_INFO))

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var charm_roll = statistic_check.charm_check()
		
	if (charm_roll):
		var sympathy_added: int = statistic_check.sympathy_added(Constants.ACTION_EFFECT_PROPAGANDA_SYMPATHY_MIN, Constants.ACTION_EFFECT_PROPAGANDA_SYMPATHY_MAX)

		log_message = "Succeeded charm check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		poi.poi_owner.char_sympathy += sympathy_added

		log_message = poi.poi_owner.char_full_name + " sympathy increased by " + str(sympathy_added)
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed charm check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	# emit stats change
	EventBus.stat_created.emit("propaganda", charm_roll)
	# emit stats change
	EventBus.stat_created.emit("missions", charm_roll)

	if poi.poi_owner.char_sympathy >= Constants.NEW_SYMPATHISER_THRESHOLD:
		print("Sympathy is now high enough to trigger a new sympathiser event")
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.NEW_SYMPATHISER, [poi.poi_owner] as Array[Character], poi)

	return logs
