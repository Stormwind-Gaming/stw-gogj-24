extends BaseAction

class_name EspionageAction


func _process_action() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	logs.append(TurnLog.new("Processing ESPIONAGE action at [u]" + str(poi.poi_name) + "[/u] by " + _get_character_names(), Enums.LogType.ACTION_INFO))

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var stat_check: String = ""
	var roll: Dictionary = {"success": false}

	match poi.stat_check_type:
		Enums.StatCheckType.SMARTS:
			stat_check = "smarts"
			roll = MathHelpers.bounded_sigmoid_check(stats[stat_check], true, Constants.SMARTS_CHECK_MIN_CHANCE, Constants.SMARTS_CHECK_MAX_CHANCE)

			# emit stats change
			EventBus.stat_created.emit("smarts", roll.success)
		Enums.StatCheckType.CHARM:
			stat_check = "charm"
			roll = MathHelpers.bounded_sigmoid_check(stats[stat_check], true, Constants.CHARM_CHECK_MIN_CHANCE, Constants.CHARM_CHECK_MAX_CHANCE)

			# emit stats change
			EventBus.stat_created.emit("charm", roll.success)
		
	if (roll.success):
		log_message = "Succeeded " + stat_check + " check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		var rumour: Rumour = IntelFactory.create_rumour(poi.rumour_config)

		log_message = "Generated intel of type " + str(rumour.rumour_type)
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed " + stat_check + " check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))
	
	# emit stats change
	EventBus.stat_created.emit("espionage", roll.success)
	# emit stats change
	EventBus.stat_created.emit("missions", roll.success)

	return logs
