extends BaseAction

class_name PropagandaAction


func _process_action() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	logs.append("Processing PROPAGANDA action at [u]" + str(poi.poi_name) + "[/u] by " + _get_character_names())

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var charm_roll = MathHelpers.bounded_sigmoid_check(stats["charm"], true)
		
	if(charm_roll.success):
		log_message = "Succeeded charm check..."
		logs.append(log_message)

		poi.poi_owner.char_sympathy += Constants.ACTION_EFFECT_PROPAGANDA_SYMPATHY_MODIFIER

		log_message = poi.poi_owner.char_full_name + " sympathy increased by " + str(Constants.ACTION_EFFECT_PROPAGANDA_SYMPATHY_MODIFIER)
		logs.append(log_message)

	else:
		log_message = "Failed charm check..."
		logs.append(log_message)

	return logs
