extends Node

#|==============================|
#|    Milestones passed         |
#|==============================|
"""
@brief Values holding whether the milestone has been passed
"""

var military_bonus_active: bool = false
var civic_bonus_active: bool = false
var industry_bonus_active: bool = false
var residential_bonus_active: bool = false
var port_bonus_active: bool = false

var global_heat_breakpoint_low: bool = true # 0
var global_heat_breakpoint_medium: bool = false # 35
var global_heat_breakpoint_high: bool = false # 70

var global_sympathy_breakpoint_low: bool = false # 30
var global_sympathy_breakpoint_medium: bool = false # 45
var global_sympathy_breakpoint_high: bool = false # 60

#|==============================|
#|    Milestones management     |
#|==============================|

"""
@brief Set the military bonus

@param value: the value to set the bonus to
"""
func set_military_bonus(value: bool):
	military_bonus_active = value

"""
@brief Set the civic bonus

@param value: the value to set the bonus to
"""
func set_civic_bonus(value: bool):
	civic_bonus_active = value

"""
@brief Set the industry bonus

@param value: the value to set the bonus to
"""
func set_industry_bonus(value: bool):
	industry_bonus_active = value

"""
@brief Set the residential bonus

@param value: the value to set the bonus to
"""
func set_residential_bonus(value: bool):
	residential_bonus_active = value

"""
@brief Set the port bonus

@param value: the value to set the bonus to
"""
func set_port_bonus(value: bool):
	port_bonus_active = value


#|==============================|
#|      Lifecycle Methods       |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Sets up signals to listen for changes
"""
func _ready() -> void:
	EventBus.end_turn_complete.connect(_check_milestones)
	
"""
@brief Checks if any milestones have been passed
"""
func _check_milestones(_num: int) -> void:
	# get districts
	var districts = GlobalRegistry.districts.get_all_items()

	# check if any of the districts have passed the milestone
	for district in districts:
		if district.district_type == Enums.DistrictType.MILITARY:
			if district.heat > 66:
				set_military_bonus(true)
				EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.EVENT_MILITARY_MILESTONE, [] as Array[Character], district.pois[0])
			else:
				set_military_bonus(false)
		elif district.district_type == Enums.DistrictType.CIVIC:
			if district.heat > 66:
				set_civic_bonus(true)
				EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.EVENT_CIVIC_MILESTONE, [] as Array[Character], district.pois[0])
			else:
				set_civic_bonus(false)
		elif district.district_type == Enums.DistrictType.INDUSTRIAL:
			if district.heat > 66:
				set_industry_bonus(true)
				EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.EVENT_INDUSTRIAL_MILESTONE, [] as Array[Character], district.pois[0])
			else:
				set_industry_bonus(false)
		elif district.district_type == Enums.DistrictType.RESIDENTIAL:
			if district.heat > 66:
				set_residential_bonus(true)
				EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.EVENT_RESIDENTIAL_MILESTONE, [] as Array[Character], district.pois[0])
			else:
				set_residential_bonus(false)
		elif district.district_type == Enums.DistrictType.PORT:
			if district.heat > 66:
				set_port_bonus(true)
				EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.EVENT_PORT_MILESTONE, [] as Array[Character], district.pois[0])
			else:
				set_port_bonus(false)
	
	# check if any global milestones have been passed
	var global_heat = GameController.get_heat_level()

	if not global_heat_breakpoint_medium and global_heat >= 35:
		global_heat_breakpoint_medium = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.HEAT_BREAKPOINT_MEDIUM, [] as Array[Character], null)
	if not global_heat_breakpoint_high and global_heat >= 70:
		global_heat_breakpoint_high = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.HEAT_BREAKPOINT_HIGH, [] as Array[Character], null)

	var global_sympathy = GameController.get_resistance_level()

	if not global_sympathy_breakpoint_low and global_sympathy >= 30:
		global_sympathy_breakpoint_low = true
	if not global_sympathy_breakpoint_medium and global_sympathy >= 45:
		global_sympathy_breakpoint_medium = true
	if not global_sympathy_breakpoint_high and global_sympathy >= 60:
		global_sympathy_breakpoint_high = true
	



#|==============================|
#|    Value Management          |
#|==============================|

"""
@brief Modifies the stat based on the district type modifier

@param stat_to_modify: the stat to modify
@param stat_type: the type of the stat to modify
"""
func character_stat_modification(stat_to_modify: int, stat_type: Enums.StatCheckType) -> int:
	var modifier = 0

	if stat_type == Enums.StatCheckType.SUBTLETY:
		if military_bonus_active:
			modifier += Constants.MILITARY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
	elif stat_type == Enums.StatCheckType.SMARTS:
		if industry_bonus_active:
			modifier += Constants.INDUSTRY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
	elif stat_type == Enums.StatCheckType.CHARM:
		if civic_bonus_active:
			modifier += Constants.CIVIC_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
	
	return stat_to_modify + modifier

"""
@brief Modifies the heat based on the district type modifier

@param heat: the heat to modify
@param district_type: the type of the district
"""
func heat_modification(heat: int, district_type: Enums.DistrictType) -> int:
	var modifier = 1
	
	if district_type == Enums.DistrictType.CIVIC:
			modifier *= Constants.CIVIC_DISTRICT_MODIFIER_BASE
	
	if port_bonus_active:
		modifier *= Constants.PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE

	return floor(heat * modifier)

"""
@brief Modifies the sympathy based on the district type modifier

@param sympathy: the sympathy to modify
@param district_type: the type of the district
"""
func sympathy_modification(sympathy: int, district_type: Enums.DistrictType) -> int:
	var modifier = 1

	if district_type == Enums.DistrictType.MILITARY:
		modifier *= Constants.MILITARY_DISTRICT_MODIFIER_BASE

	if residential_bonus_active:
		modifier *= Constants.RESIDENTIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE

	return floor(sympathy * modifier)

"""
@brief Modifies the injury based on the district type modifier

@param injury: the injury to modify
@param district_type: the type of the district
"""
func injury_chance_modification(injury: int, district_type: Enums.DistrictType) -> int:
	var modifier = 1

	if district_type == Enums.DistrictType.INDUSTRIAL:
		modifier *= Constants.INDUSTRY_DISTRICT_MODIFIER_BASE

	return injury * modifier

"""
@brief Modifies the mission duration based on the district type modifier

@param mission_duration: the mission duration to modify
@param district_type: the type of the district
"""
func mission_duration_modification(mission_duration: int, district_type: Enums.DistrictType) -> int:
	var modified_mission_duration: int = mission_duration

	if district_type == Enums.DistrictType.PORT:
		modified_mission_duration += Constants.PORT_DISTRICT_MODIFIER_BASE

	return modified_mission_duration