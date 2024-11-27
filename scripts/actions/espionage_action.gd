extends BaseAction

class_name EspionageAction


func _process_action() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""
	var id = GlobalRegistry.pois.get_all_items().find(poi)
	var character_id = GlobalRegistry.characters.get_all_items().find(characters[0])
	var message: String = "[u]ESPIONAGE[/u] undertaken by [url=character:%s]%s[/url] at [url=poi:%s]%s[/url]." % [character_id, _get_character_names(), id, poi.poi_name]
	logs.append(TurnLog.new(message, Enums.LogType.ACTION_INFO))

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var stat_check: String = ""
	var success: bool = false

	print("Action requires: ", poi.stat_check_type)

	match poi.stat_check_type:
		Enums.StatCheckType.SMARTS:
			stat_check = "smarts"
			success = statistic_check.smarts_check()

		Enums.StatCheckType.CHARM:
			stat_check = "charm"
			success = statistic_check.charm_check()
		
	if (success):
		# log_message = "Succeeded " + stat_check + " check..."
		# logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		for i in range(statistic_check.intel_added(1)):
			var rumour: Rumour = IntelFactory.create_rumour(poi.rumour_config)

			log_message = "A new %s rumor reaches us.  Whispers fill the air, weaving another thread into our growing web of intel." % Globals.get_intel_type_string(rumour.rumour_type)
			logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "The effort has faltered; the occupiers have tightened their hold. We must learn from this and press on."
		logs.append(TurnLog.new(log_message, Enums.LogType.CONSEQUENCE))
	
	# emit stats change
	EventBus.stat_created.emit("espionage", success)
	# emit stats change
	EventBus.stat_created.emit("missions", success)

	return logs
