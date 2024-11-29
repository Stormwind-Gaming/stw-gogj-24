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

	var id = ReferenceGetter.global_registry().pois.get_all_items().find(poi)
	var character_id = ReferenceGetter.global_registry().characters.get_all_items().find(characters[0])
	var message: String = "[u]PLAN[/u] undertaken by [url=character:%s]%s[/url] at [url=poi:%s]%s[/url]." % [character_id, _get_character_names(), id, poi.poi_name]
	logs.append(TurnLog.new(message, Enums.LogType.ACTION_INFO))

	match associated_plan.plan_effect:
		Enums.IntelEffect.BUILD_SYMPATHY:
			logs += _build_sympathy()
		Enums.IntelEffect.BUILD_SYMPATHY_ALL:
			logs += _build_sympathy_all()
		Enums.IntelEffect.DISCOVER_ALL:
			logs += _discover_all()
		Enums.IntelEffect.ADD_AGENT_SLOT:
			logs += _add_agent_slot()
		Enums.IntelEffect.RESCUE_AGENT:
			logs += _rescue_agent()
		Enums.IntelEffect.WILDCARD_INTEL:
			logs += _wildcard_intel()
		Enums.IntelEffect.REDUCE_HEAT:
			logs += _reduce_heat()
		Enums.IntelEffect.REDUCE_HEAT_ALL:
			logs += _reduce_heat_all()
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

	var base_sympathy_added: int = MathHelpers.generate_bell_curve_stat(Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MIN, Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MAX)
	var sympathy_added: int = base_sympathy_added

	associated_plan.plan_subject_character.char_sympathy += sympathy_added

	var character_id = ReferenceGetter.global_registry().characters.get_all_items().find(associated_plan.plan_subject_character)
	log_message = "A breakthrough: [url=character:%s]%s[/url] grows closer to our cause.  Their eyes now see the truth of the occupation, and their heart leans towards freedom." % [character_id, associated_plan.plan_subject_character.char_full_name]
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Builds sympathy for all characters in the POI's district
"""
func _build_sympathy_all() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	for my_poi in ReferenceGetter.global_registry().poi.find_all_items(ReferenceGetter.global_registry().LIST_ALL_POIS, "parent_district", poi.parent_district):
		var base_sympathy_added: int = MathHelpers.generate_bell_curve_stat(Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_ALL_MIN, Constants.ACTION_EFFECT_PLAN_BUILD_SYMPATHY_ALL_MAX)
		var sympathy_added: int = base_sympathy_added

		my_poi.poi_owner.char_sympathy += sympathy_added

		var id = ReferenceGetter.global_registry().districts.get_all_items().find(associated_plan.plan_subject_poi.parent_district)
		log_message = "The hearts of [url=district:%s]%s[/url] have softened. A tide of sympathy washes through, bolstering our efforts." % [id, associated_plan.plan_subject_poi.parent_district.district_name]
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Discovers all characters in the POI's district
"""
func _discover_all() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	for my_poi in ReferenceGetter.global_registry().pois.find_all_items(ReferenceGetter.global_registry().LIST_ALL_POIS, "parent_district", poi.parent_district):
		my_poi.poi_owner.char_recruitment_state = Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN

	var id = ReferenceGetter.global_registry().districts.get_all_items().find(associated_plan.plan_subject_poi.parent_district)
	log_message = "Our knowledge deepens: all characters in [url=district:%s]%s[/url] are now known. The veil has lifted, and their faces are no longer strangers to us." % [id, associated_plan.plan_subject_poi.parent_district.district_name]
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Adds an agent slot
"""
func _add_agent_slot() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	ReferenceGetter.game_controller().agent_modifier += 1

	log_message = "A new ally can be called to our ranks. The network expands. Another brave soul joins the fight for freedom."
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Rescues an agent
"""
func _rescue_agent() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	associated_plan.plan_subject_character.char_state = Enums.CharacterState.AVAILABLE
	associated_plan.plan_subject_character.char_recruitment_state = Enums.CharacterRecruitmentState.SYMPATHISER_NOT_RECRUITED

	var character_id = ReferenceGetter.global_registry().characters.get_all_items().find(associated_plan.plan_subject_character)
	log_message = "[url=character:%s]%s[/url] has been freed and welcomed back to the fold. Their liberation is a victory, and their spirit remains unbroken." % [character_id, associated_plan.plan_subject_character.char_full_name]
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Adds a wildcard intel
"""
func _wildcard_intel() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	for i in range(0, 4):
		var rumour: Rumour = IntelFactory.create_rumour(RumourConfig.new(33, 33, 33))

		log_message = "A new %s rumor reaches us. Whispers fill the air, weaving another thread into our growing web of intel." % Globals.get_intel_type_string(rumour.rumour_type)
		logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs


"""
@brief Reduces the heat of a specific district
"""
func _reduce_heat() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var base_heat_reduced: int = MathHelpers.generate_bell_curve_stat(Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_MIN, Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_MAX)

	poi.parent_district.heat -= base_heat_reduced

	var id = ReferenceGetter.global_registry().districts.get_all_items().find(associated_plan.plan_subject_poi.parent_district)
	log_message = "The pressure eases in [url=district:%s]%s[/url]. The eyes of the oppressors shift away, giving us precious breathing room." % [id, associated_plan.plan_subject_poi.parent_district.district_name]
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs

"""
@brief Reduces the heat of all districts
"""
func _reduce_heat_all() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	for district in ReferenceGetter.global_registry().districts.get_all_items():
		var base_heat_reduced: int = MathHelpers.generate_bell_curve_stat(Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MIN, Constants.ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MAX)

		district.heat -= base_heat_reduced

	log_message = "The burden lifts across all districts. A rare reprieve as the enemy's grip slackens, if only for a moment."
	logs.append(TurnLog.new(log_message, Enums.LogType.SUCCESS))

	return logs
