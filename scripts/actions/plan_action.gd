extends BaseAction

class_name PlanAction


func _process_action() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	logs.append("Processing PLAN action at [u]" + str(poi.poi_name) + "[/u] by " + str(characters))

	match associated_plan.plan_effect:
		Enums.IntelEffect.BUILD_SYMPATHY:
			return _build_sympathy()
		Enums.IntelEffect.BUILD_SYMPATHY_ALL:
			return _build_sympathy_all()
		Enums.IntelEffect.DISCOVER_ALL:
			return _discover_all()
		Enums.IntelEffect.ADD_AGENT_SLOT:
			return _add_agent_slot()
		Enums.IntelEffect.RESCUE_AGENT:
			return _rescue_agent()
		Enums.IntelEffect.WILDCARD_INTEL:
			return _wildcard_intel()
		Enums.IntelEffect.REDUCE_HEAT:
			return _reduce_heat()
		Enums.IntelEffect.REDUCE_HEAT_ALL:
			return _reduce_heat_all()
		_:
			log_message = "No effect for plan"
			logs.append(log_message)

	return logs

func _build_sympathy() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var charm_roll = MathHelpers.bounded_sigmoid_check(stats["charm"], true)
		
	if(charm_roll.success):
		log_message = "Succeeded charm check..."
		logs.append(log_message)

		associated_plan.plan_subject_character.char_sympathy += Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MODIFIER

		log_message = associated_plan.plan_subject_character.char_full_name + " sympathy increased by " + str(Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MODIFIER)
		logs.append(log_message)

	else:
		log_message = "Failed charm check..."
		logs.append(log_message)

	return logs

func _build_sympathy_all() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	return logs

func _discover_all() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	return logs

func _add_agent_slot() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	return logs

func _rescue_agent() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	return logs

func _wildcard_intel() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	return logs

func _reduce_heat() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	return logs

func _reduce_heat_all() -> Array[String]:
	var logs: Array[String] = []
	var log_message: String = ""

	return logs
