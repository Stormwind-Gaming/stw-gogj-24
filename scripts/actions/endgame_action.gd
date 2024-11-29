extends PlanAction

class_name EndgameAction

#|==============================|
#|      Action Processing      |
#|==============================|
"""
@brief Processes the action
"""
func _process_action() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var id = GlobalRegistry.pois.get_all_items().find(poi)
	logs.append(TurnLog.new(("Processing ENDGAME PLAN action at [url=poi:%s]" % id) + str(poi.poi_name) + "[/url] by " + _get_character_names(), Enums.LogType.ACTION_INFO))

	if poi.poi_type == Enums.POIType.DOCKS:

		match GameController.heat_endgame_port_step:
			0:
				logs += _heat_endgame_port_1()
			1:
				logs += _heat_endgame_port_2()
			2:
				logs += _heat_endgame_port_3()
			3:
				logs += _heat_endgame_port_4()
			_:
				printerr("Invalid heat endgame port step: ", GameController.heat_endgame_port_step)
	
	if poi.poi_type == Enums.POIType.TRAIN_STATION:

		match GameController.heat_endgame_train_step:
			0:
				logs += _heat_endgame_train_1()
			1:
				logs += _heat_endgame_train_2()
			2:
				logs += _heat_endgame_train_3()
			3:
				logs += _heat_endgame_train_4()
			_:
				printerr("Invalid heat endgame train step: ", GameController.heat_endgame_train_step)

	if poi.poi_type == Enums.POIType.AIR_BASE:

		match GameController.resistance_endgame_step:
			0:
				logs += _resistance_endgame_1()
			1:
				logs += _resistance_endgame_2()
			2:
				logs += _resistance_endgame_3()
			3:
				logs += _resistance_endgame_4()
			4:
				logs += _resistance_endgame_5()
			_:
				printerr("Invalid resistance endgame step: ", GameController.resistance_endgame_step)

	return logs


func _process_danger() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []

	var id = GlobalRegistry.pois.get_all_items().find(poi)
	logs.append(TurnLog.new(("Processing danger for action at [url=poi:%s]" % id) + str(poi.poi_name) + "[/url] by " + _get_character_names(), Enums.LogType.ACTION_INFO))

	# Here we override the base action danger processing, for endgame actions there is a 100% chance of consequence on failure
	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var subtle_roll = statistic_check.subtlety_check()

	var log_message: String = ""
		
	if (not subtle_roll):
		# TODO: How do we add heat globally without it then being overwritten by the mean of all districts? I'll just do this for the time being...
		var districts: Array = GlobalRegistry.districts.get_all_items()
		for district in districts:
			district.heat += ceil(districts.size() / 5)

		# TODO: This is a bit of a hack, we should have a more elegant way of determining consequences during endgame
		var consequence = [Enums.CharacterState.DECEASED, Enums.CharacterState.MIA, Enums.CharacterState.INJURED].pick_random()
		var consequence_log_type: Enums.EventOutcomeType

		match consequence:
			Enums.CharacterState.INJURED:
				log_message = "One character is injured"
				characters.shuffle()
				characters[0].char_state = Enums.CharacterState.INJURED
				consequence_log_type = Enums.EventOutcomeType.INJURED

				# emit stats change
				EventBus.stat_created.emit("injured", true)
			Enums.CharacterState.MIA:
				log_message = "One character is missing"
				characters.shuffle()
				characters[0].char_state = Enums.CharacterState.MIA
				consequence_log_type = Enums.EventOutcomeType.MIA

				# emit stats change
				EventBus.stat_created.emit("mia", true)
			Enums.CharacterState.DECEASED:
				log_message = "One character is deceased"
				characters.shuffle()
				characters[0].char_state = Enums.CharacterState.DECEASED
				consequence_log_type = Enums.EventOutcomeType.DECEASED

				# emit stats change
				EventBus.stat_created.emit("dead", true)
			_:
				log_message = "Unknown consequence"

		logs.append(TurnLog.new(log_message, Enums.LogType.CONSEQUENCE, poi, characters))
		EventBus.create_new_event_panel.emit(consequence_log_type, characters, poi)

	return logs


#|==============================|
#|      Heat Endgame Actions     |
#|==============================|
func _heat_endgame_port_1() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var charm_roll = statistic_check.charm_check()

	if charm_roll:
		GameController.heat_endgame_port_step = 1
		GlobalRegistry.intel.clear_list(GlobalRegistry.LIST_PLANS)

		var plan_properties = Plan.PlanProperties.new()
		var docks_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.DOCKS)
		plan_properties.plan_name = "Sneak into the Port"
		plan_properties.plan_text = "You’re outside the Port perimeter, you need to get inside as soon as possible, the best way is to wait until dark then cut through the fence south of the pier.  "
		plan_properties.plan_expiry = -1
		plan_properties.plan_subject_poi = docks_poi
		plan_properties.is_endgame_plan = true
		plan_properties.stat_check_type = Enums.StatCheckType.SMARTS
		Plan.new(plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.HEAT_PORT_02)
	else:
		logs.append(TurnLog.new("We failed to avoid detection at the checkpoint, we'll have to try again tomorrow.", Enums.LogType.ACTION_INFO, poi, characters))

	return logs

func _heat_endgame_port_2() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var smarts_roll = statistic_check.smarts_check()

	if smarts_roll:
		GameController.heat_endgame_port_step = 2
		GlobalRegistry.intel.clear_list(GlobalRegistry.LIST_PLANS)

		var plan_properties = Plan.PlanProperties.new()
		var docks_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.DOCKS)
		plan_properties.plan_name = "Board the ship."
		plan_properties.plan_text = "We don’t have long before the patrols find the gap in the fence, we must get on the ship."
		plan_properties.plan_expiry = -1
		plan_properties.plan_subject_poi = docks_poi
		plan_properties.is_endgame_plan = true
		plan_properties.stat_check_type = Enums.StatCheckType.CHARM
		Plan.new(plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.HEAT_PORT_03)
	else:
		logs.append(TurnLog.new("We failed to sneak into the port, we'll have to try again tomorrow.", Enums.LogType.ACTION_INFO, poi, characters))


	return logs

func _heat_endgame_port_3() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var charm_roll = statistic_check.charm_check()

	if charm_roll:
		GameController.heat_endgame_port_step = 3
		GlobalRegistry.intel.clear_list(GlobalRegistry.LIST_PLANS)

		var plan_properties = Plan.PlanProperties.new()
		var docks_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.DOCKS)
		plan_properties.plan_name = "Avoid the cabin search"
		plan_properties.plan_text = "The ship is leaving in 30 minutes, but first we have to avoid the customs and border patrols checking papers in every cabin. We should hide below decks in the engine room, we should be safe amongst the stevedores.\n\nWe only have one chance at this!"
		plan_properties.plan_expiry = -1
		plan_properties.plan_subject_poi = docks_poi
		plan_properties.is_endgame_plan = true
		plan_properties.stat_check_type = Enums.StatCheckType.SMARTS
		Plan.new(plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.HEAT_PORT_04)
	else:
		logs.append(TurnLog.new("We failed to board the ship, we'll have to try again tomorrow.", Enums.LogType.ACTION_INFO, poi, characters))

	return logs

func _heat_endgame_port_4() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var smarts_roll = statistic_check.smarts_check()

	if smarts_roll:
		GameController.endgame_end_type = Enums.EventOutcomeType.HEAT_PORT_SUCCESS
	else:
		GameController.endgame_end_type = Enums.EventOutcomeType.HEAT_PORT_FAILURE


	return logs

func _heat_endgame_train_1() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var smarts_roll = statistic_check.smarts_check()

	if smarts_roll:
		GameController.heat_endgame_train_step = 1
		GlobalRegistry.intel.clear_list(GlobalRegistry.LIST_PLANS)

		var plan_properties = Plan.PlanProperties.new()
		var train_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.TRAIN_STATION)
		plan_properties.plan_name = "Sneak into the Train Station"
		plan_properties.plan_text = "You’re outside the Train station perimeter, you need to get inside as soon as possible, as you have the uniform of an oberlieutenant you should be able to walk through the front door
"
		plan_properties.plan_expiry = -1
		plan_properties.plan_subject_poi = train_poi
		plan_properties.is_endgame_plan = true
		plan_properties.stat_check_type = Enums.StatCheckType.CHARM
		Plan.new(plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.HEAT_TRAIN_02)
	else:
		logs.append(TurnLog.new("We failed to avoid detection at the checkpoint, we'll have to try again tomorrow.", Enums.LogType.ACTION_INFO, poi, characters))


	return logs

func _heat_endgame_train_2() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var charm_roll = statistic_check.charm_check()

	if charm_roll:
		GameController.heat_endgame_train_step = 2
		GlobalRegistry.intel.clear_list(GlobalRegistry.LIST_PLANS)

		var plan_properties = Plan.PlanProperties.new()
		var train_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.TRAIN_STATION)
		plan_properties.plan_name = "Board a train."
		plan_properties.plan_text = "I fear that this uniform has got us as far as we can go, we need to change and board a train as a member of the crew. There is a crew room on platform 3, lets try boarding as a stoker."
		plan_properties.plan_expiry = -1
		plan_properties.plan_subject_poi = train_poi
		plan_properties.is_endgame_plan = true
		plan_properties.stat_check_type = Enums.StatCheckType.SMARTS
		Plan.new(plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.HEAT_TRAIN_03)
	else:
		logs.append(TurnLog.new("We failed to sneak into the train station, we'll have to try again tomorrow.", Enums.LogType.ACTION_INFO, poi, characters))

	return logs

func _heat_endgame_train_3() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var smarts_roll = statistic_check.smarts_check()

	if smarts_roll:
		GameController.heat_endgame_train_step = 3
		GlobalRegistry.intel.clear_list(GlobalRegistry.LIST_PLANS)

		var plan_properties = Plan.PlanProperties.new()
		var train_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.TRAIN_STATION)
		plan_properties.plan_name = "Join the boiler crew without raising alarm"
		plan_properties.plan_text = "The train is about to leave, you have to get aboard now. The stoker crew are on their way, infiltrate the team and persuade  them that you’ve been sent to join the train.\n\nWe only have one chance at this!  "
		plan_properties.plan_expiry = -1
		plan_properties.plan_subject_poi = train_poi
		plan_properties.is_endgame_plan = true
		plan_properties.stat_check_type = Enums.StatCheckType.CHARM
		Plan.new(plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.HEAT_TRAIN_04)
	else:
		logs.append(TurnLog.new("We failed to board the train, we'll have to try again tomorrow.", Enums.LogType.ACTION_INFO, poi, characters))

	return logs

func _heat_endgame_train_4() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var charm_roll = statistic_check.charm_check()

	if charm_roll:
		GameController.endgame_end_type = Enums.EventOutcomeType.HEAT_TRAIN_SUCCESS
	else:
		GameController.endgame_end_type = Enums.EventOutcomeType.HEAT_TRAIN_FAILURE

	return logs

func _resistance_endgame_1() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var smarts_roll = statistic_check.smarts_check()

	if smarts_roll:
		GameController.resistance_endgame_step = 1

		var airbase_plan_properties = Plan.PlanProperties.new()
		var airbase_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.AIR_BASE)
		airbase_plan_properties.plan_name = "Infiltrate the airbase"
		airbase_plan_properties.plan_text = "We made it through the checkpoint, but we are outside the fence, the best option we have is to get the truck through the west gate, its less busy and the guards will be tired from a night of duty "
		airbase_plan_properties.plan_expiry = -1
		airbase_plan_properties.plan_subject_poi = airbase_poi
		airbase_plan_properties.is_endgame_plan = true
		airbase_plan_properties.stat_check_type = Enums.StatCheckType.CHARM
		Plan.new(airbase_plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.RESISTANCE_AIRFIELD_02)
	else:
		logs.append(TurnLog.new("We failed to avoid detection at the checkpoint, we'll have to try again tomorrow.", Enums.LogType.ACTION_INFO, poi, characters))

	return logs

func _resistance_endgame_2() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var charm_roll = statistic_check.charm_check()

	if charm_roll:
		GameController.resistance_endgame_step = 2

		var airbase_plan_properties = Plan.PlanProperties.new()
		var airbase_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.AIR_BASE)
		airbase_plan_properties.plan_name = "Lets plant some explosives"
		airbase_plan_properties.plan_text = "We’re in! and quietly, no one knows we are here, so we have some time to plant the explosives. Get close to the aircraft and try to get near the fuel tank through the landing gear."
		airbase_plan_properties.plan_expiry = -1
		airbase_plan_properties.plan_subject_poi = airbase_poi
		airbase_plan_properties.is_endgame_plan = true
		airbase_plan_properties.stat_check_type = Enums.StatCheckType.SMARTS
		Plan.new(airbase_plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.RESISTANCE_AIRFIELD_03)
	else:
		logs.append(TurnLog.new("We failed to infiltrate the airbase, we'll have to try again tomorrow.", Enums.LogType.ACTION_INFO, poi, characters))

	return logs

func _resistance_endgame_3() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var smarts_roll = statistic_check.smarts_check()

	if smarts_roll:
		GameController.resistance_endgame_step = 4

		var airbase_plan_properties = Plan.PlanProperties.new()
		var airbase_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.AIR_BASE)
		airbase_plan_properties.plan_name = "Lets get out"
		airbase_plan_properties.plan_text = "Its time to get out, we’ve planted the explosives and the fuses are set, we will go via the east gate, away from the city and wait until the bombs go off. In the confusion and chaos we can get through the gate guards, or kill them."
		airbase_plan_properties.plan_expiry = -1
		airbase_plan_properties.plan_subject_poi = airbase_poi
		airbase_plan_properties.is_endgame_plan = true
		airbase_plan_properties.stat_check_type = Enums.StatCheckType.CHARM
		Plan.new(airbase_plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.RESISTANCE_AIRFIELD_05)
	else:
		GameController.resistance_endgame_step = 3

		var airbase_plan_properties = Plan.PlanProperties.new()
		var airbase_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.AIR_BASE)
		airbase_plan_properties.plan_name = "Hurry, we have to move fast"
		airbase_plan_properties.plan_text = "We made it in, but they know we’re here, and the alarm has sounded. Quickly head for the aircraft, plant explosives whereever we can, short fuses and lets hope we can make it work in the confusion."
		airbase_plan_properties.plan_expiry = -1
		airbase_plan_properties.plan_subject_poi = airbase_poi
		airbase_plan_properties.is_endgame_plan = true
		airbase_plan_properties.stat_check_type = Enums.StatCheckType.SMARTS
		Plan.new(airbase_plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.RESISTANCE_AIRFIELD_04)
		logs.append(TurnLog.new("We were caught planting the explosives! The alarm has been sounded!", Enums.LogType.ACTION_INFO, poi, characters))

	return logs

func _resistance_endgame_4() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var smarts_roll = statistic_check.smarts_check()

	if smarts_roll:
		GameController.resistance_endgame_step = 4

		var airbase_plan_properties = Plan.PlanProperties.new()
		var airbase_poi = GlobalRegistry.pois.find_item(GlobalRegistry.LIST_ALL_POIS, "poi_type", Enums.POIType.AIR_BASE)
		airbase_plan_properties.plan_name = "Lets get out"
		airbase_plan_properties.plan_text = "Its time to get out, we’ve planted the explosives and the fuses are set, we will go via the east gate, away from the city and wait until the bombs go off. In the confusion and chaos we can get through the gate guards, or kill them."
		airbase_plan_properties.plan_expiry = -1
		airbase_plan_properties.plan_subject_poi = airbase_poi
		airbase_plan_properties.is_endgame_plan = true
		airbase_plan_properties.stat_check_type = Enums.StatCheckType.CHARM
		Plan.new(airbase_plan_properties)

		# popup new endgame event panel
		EventBus.new_endgame_step.emit(Enums.EventOutcomeType.RESISTANCE_AIRFIELD_05)
	else:
		GameController.endgame_end_type = Enums.EventOutcomeType.GAME_OVER

	return logs

func _resistance_endgame_5() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []
	var log_message: String = ""

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var charm_roll = statistic_check.charm_check()

	if charm_roll:
		GameController.resistance_endgame_step = 5
		logs.append(TurnLog.new("YOU WIN! Resistance endgame complete!", Enums.LogType.ACTION_INFO))
		GameController.endgame_end_type = Enums.EventOutcomeType.RESISTANCE_AIRFIELD_SUCCESS
	else:
		GameController.endgame_end_type = Enums.EventOutcomeType.RESISTANCE_AIRFIELD_SUCCESS

	return logs
