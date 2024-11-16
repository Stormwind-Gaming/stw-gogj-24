extends BaseAction

class_name PropagandaAction


func _process_action() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	logs.append(TurnLog.new("Processing PROPAGANDA action at [u]" + str(poi.poi_name) + "[/u] by " + _get_character_names(), Enums.LogType.ACTION_INFO))

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var charm_roll = MathHelpers.bounded_sigmoid_check(stats["charm"], true)
		
	if(charm_roll.success):
		log_message = "Succeeded charm check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		poi.poi_owner.char_sympathy += Constants.ACTION_EFFECT_PROPAGANDA_SYMPATHY_MODIFIER

		log_message = poi.poi_owner.char_full_name + " sympathy increased by " + str(Constants.ACTION_EFFECT_PROPAGANDA_SYMPATHY_MODIFIER)
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed charm check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	return logs
