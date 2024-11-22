extends BaseAction

class_name EspionageAction


func _process_action() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	logs.append(TurnLog.new("Processing ESPIONAGE action at [u]" + str(poi.poi_name) + "[/u] by " + _get_character_names(), Enums.LogType.ACTION_INFO))

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var stat_check: String = ""
	var success: bool = false

	match poi.stat_check_type:
		Enums.StatCheckType.SMARTS:
			stat_check = "smarts"
			success = statistic_check.smarts_check()

		Enums.StatCheckType.CHARM:
			stat_check = "charm"
			success = statistic_check.charm_check()
		
	if (success):
		log_message = "Succeeded " + stat_check + " check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		for i in range(statistic_check.intel_added(1)):
			var rumour: Rumour = IntelFactory.create_rumour(poi.rumour_config)

			log_message = "Discovered a %s intel type." % Globals.get_intel_type_string(rumour.rumour_type)
			logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed " + stat_check + " check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))
	
	# emit stats change
	EventBus.stat_created.emit("espionage", success)
	# emit stats change
	EventBus.stat_created.emit("missions", success)

	return logs
