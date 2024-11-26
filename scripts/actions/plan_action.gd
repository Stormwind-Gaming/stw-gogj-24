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

	# emit stats change
	EventBus.stat_created.emit("missions", true)

	return logs

"""
@brief Builds sympathy for a specific character
"""
func _build_sympathy() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var base_sympathy_added: int = MathHelpers.generateBellCurveStat(Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MIN, Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MAX)
	var sympathy_added: int = base_sympathy_added

	associated_plan.plan_subject_character.char_sympathy += sympathy_added

	log_message = associated_plan.plan_subject_character.char_full_name + " sympathy increased by " + str(sympathy_added)
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Builds sympathy for all characters in the POI's district
"""
func _build_sympathy_all() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	for my_poi in GlobalRegistry.poi.find_all_items(GlobalRegistry.LIST_ALL_POIS, "parent_district", poi.parent_district):
		var base_sympathy_added: int = MathHelpers.generateBellCurveStat(Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_ALL_MIN, Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_ALL_MAX)
		var sympathy_added: int = base_sympathy_added

		my_poi.poi_owner.char_sympathy += sympathy_added

		log_message = my_poi.poi_owner.char_full_name + " sympathy increased by " + str(sympathy_added)
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Discovers all characters in the POI's district
"""
func _discover_all() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	for my_poi in GlobalRegistry.pois.find_all_items(GlobalRegistry.LIST_ALL_POIS, "parent_district", poi.parent_district):
		my_poi.poi_owner.char_recruitment_state = Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN

		log_message = my_poi.poi_owner.char_full_name + " is now known to us"
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Adds an agent slot
"""
func _add_agent_slot() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	GameController.max_agents += 1

	log_message = "Max agents increased by 1"
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Rescues an agent
"""
func _rescue_agent() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	associated_plan.plan_subject_character.char_state = Enums.CharacterState.AVAILABLE
	associated_plan.plan_subject_character.char_recruitment_state = Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN

	log_message = associated_plan.plan_subject_character.char_full_name + " has been rescued"
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Adds a wildcard intel
"""
func _wildcard_intel() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	for i in range(0, 4):
		IntelFactory.create_rumour(RumourConfig.new(33, 33, 33))

	log_message = "Added 4 rumours"
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs


"""
@brief Reduces the heat of a specific POI
"""
func _reduce_heat() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var base_heat_reduced: int = MathHelpers.generateBellCurveStat(Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_MIN, Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_MAX)

	poi.parent_district.heat -= base_heat_reduced

	log_message = poi.parent_district.district_name + " heat reduced by " + str(base_heat_reduced)
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Reduces the heat of all districts
"""
func _reduce_heat_all() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	for district in GlobalRegistry.districts.get_all_items():
		var base_heat_reduced: int = MathHelpers.generateBellCurveStat(Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MIN, Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MAX)

		district.heat -= base_heat_reduced

		log_message = district.district_name + " heat reduced by " + str(base_heat_reduced)
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs
