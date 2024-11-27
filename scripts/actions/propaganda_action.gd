extends BaseAction

class_name PropagandaAction


func _process_action() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var id = GlobalRegistry.pois.get_all_items().find(poi)
	var character_id = GlobalRegistry.characters.get_all_items().find(characters[0])
	var message: String = "[u]PROPAGANDA[/u] undertaken by [url=character:%s]%s[/url] at [url=poi:%s]%s[/url]." % [character_id, _get_character_names(), id, poi.poi_name]
	logs.append(TurnLog.new(message, Enums.LogType.ACTION_INFO))

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var charm_roll = statistic_check.charm_check()
		
	if (charm_roll):
		var sympathy_added: int = statistic_check.sympathy_added(Constants.ACTION_EFFECT_PROPAGANDA_SYMPATHY_MIN, Constants.ACTION_EFFECT_PROPAGANDA_SYMPATHY_MAX)

		# log_message = "Succeeded charm check..."
		# logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		poi.poi_owner.char_sympathy += sympathy_added

		var owner_character_id = GlobalRegistry.characters.get_all_items().find(poi.poi_owner)
		log_message = "A breakthrough: [url=character:%s]%s[/url] grows closer to our cause. Their eyes now see the truth of the occupation, and their heart leans towards freedom." % [owner_character_id, poi.poi_owner.char_full_name]
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "The effort has faltered; the occupiers have tightened their hold. We must learn from this and press on."
		logs.append(TurnLog.new(log_message, Enums.LogType.CONSEQUENCE))

	# emit stats change
	EventBus.stat_created.emit("propaganda", charm_roll)
	# emit stats change
	EventBus.stat_created.emit("missions", charm_roll)

	return logs
