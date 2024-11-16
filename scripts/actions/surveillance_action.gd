extends BaseAction

class_name SurveillanceAction


func _process_action() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	logs.append("Processing SURVEILLANCE action at [u]" + str(poi.poi_name) + "[/u] by " + _get_character_names())

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var smarts_roll = MathHelpers.bounded_sigmoid_check(stats["smarts"], true)
		
	if(smarts_roll.success):
		log_message = "Succeeded smarts check..."
		logs.append(log_message)

		poi.poi_owner.char_recruitment_state = Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN

		log_message = poi.poi_owner.char_full_name + " is now known to us"
		logs.append(log_message)

	else:
		log_message = "Failed smarts check..."
		logs.append(log_message)

	return logs
