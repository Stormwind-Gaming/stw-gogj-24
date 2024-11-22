extends BaseAction

class_name SurveillanceAction


func _process_action() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	logs.append(TurnLog.new("Processing SURVEILLANCE action at [u]" + str(poi.poi_name) + "[/u] by " + _get_character_names(), Enums.LogType.ACTION_INFO))

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)
	var smarts_roll = statistic_check.smarts_check()

	if (smarts_roll):
		log_message = "Succeeded smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		poi.poi_owner.char_recruitment_state = Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN

		log_message = poi.poi_owner.char_full_name + " is now known to us"
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	# emit stats change
	EventBus.stat_created.emit("surveillance", smarts_roll)
	# emit stats change
	EventBus.stat_created.emit("missions", smarts_roll)

	return logs
