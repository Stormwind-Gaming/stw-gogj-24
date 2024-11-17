extends BaseAction

class_name PlanAction


#|==============================|
#|      Action Processing      |
#|==============================|
"""
@brief Processes the action
"""
func _process_action() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	logs.append(TurnLog.new("Processing PLAN action at [u]" + str(poi.poi_name) + "[/u] by " + _get_character_names(), Enums.LogType.ACTION_INFO))

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
			logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	return logs

"""
@brief Builds sympathy for a specific character
"""
func _build_sympathy() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var charm_roll = MathHelpers.bounded_sigmoid_check(stats["charm"], true, Constants.CHARM_CHECK_MIN_CHANCE, Constants.CHARM_CHECK_MAX_CHANCE)
		
	if(charm_roll.success):
		var sympathy_added: int = StatisticModification.sympathy_modification(Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MODIFIER, poi.parent_district.district_type)

		log_message = "Succeeded charm check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		associated_plan.plan_subject_character.char_sympathy += sympathy_added

		log_message = associated_plan.plan_subject_character.char_full_name + " sympathy increased by " + str(sympathy_added)
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed charm check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	return logs

"""
@brief Builds sympathy for all characters in the POI's district
"""
func _build_sympathy_all() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var charm_roll = MathHelpers.bounded_sigmoid_check(stats["charm"], true, Constants.CHARM_CHECK_MIN_CHANCE, Constants.CHARM_CHECK_MAX_CHANCE)
		
	if(charm_roll.success):
		log_message = "Succeeded charm check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		for my_poi in GlobalRegistry.poi.find_all_items(GlobalRegistry.LIST_ALL_POIS, "parent_district", poi.parent_district):
			my_poi.poi_owner.char_sympathy += Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_ALL_MODIFIER

			log_message = my_poi.poi_owner.char_full_name + " sympathy increased by " + str(Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_ALL_MODIFIER)
			logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed charm check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	return logs

"""
@brief Discovers all characters in the POI's district
"""
func _discover_all() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var smarts_roll = MathHelpers.bounded_sigmoid_check(stats["smarts"], true, Constants.SMARTS_CHECK_MIN_CHANCE, Constants.SMARTS_CHECK_MAX_CHANCE)
		
	if(smarts_roll.success):
		log_message = "Succeeded smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		for my_poi in GlobalRegistry.poi.find_all_items(GlobalRegistry.LIST_POI, "parent_district", poi.parent_district):
			my_poi.poi_owner.char_recruitment_state = Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN

			log_message = my_poi.poi_owner.char_full_name + " is now known to us"
			logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	return logs

"""
@brief Adds an agent slot
"""
func _add_agent_slot() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var smarts_roll = MathHelpers.bounded_sigmoid_check(stats["smarts"], true, Constants.SMARTS_CHECK_MIN_CHANCE, Constants.SMARTS_CHECK_MAX_CHANCE)
		
	if(smarts_roll.success):
		log_message = "Succeeded smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		GameController.max_agents += 1

		log_message = "Max agents increased by 1"
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	return logs

"""
@brief Rescues an agent
"""
func _rescue_agent() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var smarts_roll = MathHelpers.bounded_sigmoid_check(stats["smarts"], true, Constants.SMARTS_CHECK_MIN_CHANCE, Constants.SMARTS_CHECK_MAX_CHANCE)
		
	if(smarts_roll.success):
		log_message = "Succeeded smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		associated_plan.plan_subject_character.char_state = Enums.CharacterState.AVAILABLE
		associated_plan.plan_subject_character.char_recruitment_state = Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN

		log_message = associated_plan.plan_subject_character.char_full_name + " has been rescued"
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	return logs

"""
@brief Adds a wildcard intel
"""
func _wildcard_intel() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	return logs

"""
@brief Reduces the heat of a specific POI
"""
func _reduce_heat() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var smarts_roll = MathHelpers.bounded_sigmoid_check(stats["smarts"], true, Constants.SMARTS_CHECK_MIN_CHANCE, Constants.SMARTS_CHECK_MAX_CHANCE)
		
	if(smarts_roll.success):
		log_message = "Succeeded smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		poi.parent_district.heat -= Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_MODIFIER

		log_message = poi.parent_district.district_name + " heat reduced by " + str(Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_MODIFIER)
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	return logs

"""
@brief Reduces the heat of all districts
"""
func _reduce_heat_all() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	var smarts_roll = MathHelpers.bounded_sigmoid_check(stats["smarts"], true, Constants.SMARTS_CHECK_MIN_CHANCE, Constants.SMARTS_CHECK_MAX_CHANCE)
		
	if(smarts_roll.success):
		log_message = "Succeeded smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

		for district in GlobalRegistry.districts.get_all_items():
			district.heat -= Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MODIFIER

			log_message = district.district_name + " heat reduced by " + str(Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MODIFIER)
			logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	else:
		log_message = "Failed smarts check..."
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	return logs
