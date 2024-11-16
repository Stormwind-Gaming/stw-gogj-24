extends BaseAction

class_name EspionageAction


func _process_action() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	logs.append("Processing ESPIONAGE action at [u]" + str(poi.poi_name) + "[/u] by " + _get_character_names())

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var stat_check:String = ""
	match poi.stat_check_type:
		Enums.StatCheckType.SMARTS:
			stat_check = "smarts"
		Enums.StatCheckType.CHARM:
			stat_check = "charm"

	var roll = MathHelpers.bounded_sigmoid_check(stats[stat_check], true)
		
	if(roll.success):
		log_message = "Succeeded " + stat_check + " check..."
		logs.append(log_message)

		var rumour: Rumour = IntelFactory.create_rumour(poi.rumour_config)

		log_message = "Generated intel of type " + str(rumour.rumour_type)
		logs.append(log_message)

	else:
		log_message = "Failed " + stat_check + " check..."
		logs.append(log_message)

	return logs
