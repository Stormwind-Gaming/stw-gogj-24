extends BaseAction

class_name SurveillanceAction


func _process_action() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var id = ReferenceGetter.global_registry().pois.get_all_items().find(poi)
	var character_id = ReferenceGetter.global_registry().characters.get_all_items().find(characters[0])
	var message: String = "[u]SURVEILLANCE[/u] undertaken by [url=character:%s]%s[/url] at [url=poi:%s]%s[/url]." % [character_id, _get_character_names(), id, poi.poi_name]
	logs.append(TurnLog.new(message, Enums.LogType.ACTION_INFO))

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)
	var smarts_roll = statistic_check.smarts_check()

	if (smarts_roll):
		# log_message = "Succeeded smarts check..."
		# logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		poi.poi_owner.char_recruitment_state = Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN

		var district_id = ReferenceGetter.global_registry().districts.get_all_items().find(poi.parent_district)
		var owner_character_id = ReferenceGetter.global_registry().characters.get_all_items().find(poi.poi_owner)
		log_message = "Our understanding grows: [url=character:%s]%s[/url] in [url=district:%s]%s[/url] has been revealed.  No longer a mystery, their identity is now known to us." % [owner_character_id, poi.poi_owner.char_full_name, district_id, poi.parent_district.district_name]
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "The effort has faltered; the occupiers have tightened their hold. We must learn from this and press on."
		logs.append(TurnLog.new(log_message, Enums.LogType.CONSEQUENCE))

	# emit stats change
	EventBus.stat_created.emit("surveillance", smarts_roll)
	# emit stats change
	EventBus.stat_created.emit("missions", smarts_roll)

	return logs
