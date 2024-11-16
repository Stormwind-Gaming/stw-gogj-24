extends Node

#|==============================|
#| Military District Modifiers	|
#|==============================|

"""
@brief negative effect of performing an action in a military district
"""
# -50% sympathy generated
const MILITARY_DISTRICT_MODIFIER_BASE: float = 0.5
# const MILITARY_DISTRICT_MODIFIER_STAT: sympathy

"""
@brief positive effect gained from military district when over 66 percent sympathy
"""
const MILITARY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE: int = 1
const MILITARY_DISTRICT_MODIFIER_HIGH_SYMPATHY_STAT: Enums.StatCheckType = Enums.StatCheckType.SUBTLETY

#|==============================|
#|   Civic District Modifiers  	|
#|==============================|

"""
@brief negative effect of performing an action in a civic district
"""
# +25% heat generated
const CIVIC_DISTRICT_MODIFIER_BASE: float = 1.25
# const CIVIC_DISTRICT_MODIFIER_STAT: heat

"""
@brief positive effect gained from civic district when over 66 percent sympathy
"""
const CIVIC_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE: int = 1
const CIVIC_DISTRICT_MODIFIER_HIGH_SYMPATHY_STAT: Enums.StatCheckType = Enums.StatCheckType.CHARM

#|==============================|
#| Industry District Modifiers	|
#|==============================|

"""
@brief negative effect of performing an action in an industry district
"""
# +10% injury risk
const INDUSTRY_DISTRICT_MODIFIER_BASE: float = 1.1
# const INDUSTRY_DISTRICT_MODIFIER_STAT: injury

"""
@brief positive effect gained from industry district when over 66 percent sympathy
"""
const INDUSTRY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE: int = 1
const INDUSTRY_DISTRICT_MODIFIER_HIGH_SYMPATHY_STAT: Enums.StatCheckType = Enums.StatCheckType.SMARTS

#|==============================|
#|Residential District Modifiers|
#|==============================|

"""
@brief negative effect of performing an action in a residential district
"""
# +10% subtlety check failure risk
const RESIDENTIAL_DISTRICT_MODIFIER_BASE: float = 1.1
# const RESIDENTIAL_DISTRICT_MODIFIER_STAT: subtlety check

"""
@brief positive effect gained from residential district when over 66 percent sympathy
"""
const RESIDENTIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE: float = 1.25
# const RESIDENTIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_STAT: sympathy

#|==============================|
#|	Port District Modifiers			|
#|==============================|

"""
@brief negative effect of performing an action in a port district
"""
# +1 mission duration
const PORT_DISTRICT_MODIFIER_BASE: int = 1
# const PORT_DISTRICT_MODIFIER_STAT: mission duration

"""
@brief positive effect gained from port district when over 66 percent sympathy
"""
const PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE: float = 0.75
# const PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_STAT: heat


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
Sets up signals to listen for sympathy changes
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
			else:
				set_military_bonus(false)
		elif district.district_type == Enums.DistrictType.CIVIC:
			if district.heat > 66:
				set_civic_bonus(true)
			else:
				set_civic_bonus(false)
		elif district.district_type == Enums.DistrictType.INDUSTRIAL:
			if district.heat > 66:
				set_industry_bonus(true)
			else:
				set_industry_bonus(false)
		elif district.district_type == Enums.DistrictType.RESIDENTIAL:
			if district.heat > 66:
				set_residential_bonus(true)
			else:
				set_residential_bonus(false)
		elif district.district_type == Enums.DistrictType.PORT:
			if district.heat > 66:
				set_port_bonus(true)
			else:
				set_port_bonus(false)


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
			modifier += MILITARY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
	elif stat_type == Enums.StatCheckType.SMARTS:
		if industry_bonus_active:
			modifier += INDUSTRY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
	elif stat_type == Enums.StatCheckType.CHARM:
		if civic_bonus_active:
			modifier += CIVIC_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
	
	return stat_to_modify + modifier

"""
@brief Modifies the heat based on the district type modifier

@param heat: the heat to modify
@param district_type: the type of the district
"""
func heat_modification(heat: int, district_type: Enums.DistrictType) -> int:
	var modifier = 1
	
	if district_type == Enums.DistrictType.CIVIC:
			modifier *= CIVIC_DISTRICT_MODIFIER_BASE
	
	if industry_bonus_active:
		modifier *= PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE

	return floor(heat * modifier)

"""
@brief Modifies the sympathy based on the district type modifier

@param sympathy: the sympathy to modify
@param district_type: the type of the district
"""
func sympathy_modification(sympathy: int, district_type: Enums.DistrictType) -> int:
	var modifier = 1

	if district_type == Enums.DistrictType.MILITARY:
		modifier *= MILITARY_DISTRICT_MODIFIER_BASE

	if residential_bonus_active:
		modifier *= RESIDENTIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE

	return sympathy * modifier

"""
@brief Modifies the injury based on the district type modifier

@param injury: the injury to modify
@param district_type: the type of the district
"""
func injury_chance_modification(injury: int, district_type: Enums.DistrictType) -> int:
	var modifier = 1

	if district_type == Enums.DistrictType.INDUSTRIAL:
		modifier *= INDUSTRY_DISTRICT_MODIFIER_BASE

	return injury * modifier

"""
@brief Modifies the mission duration based on the district type modifier

@param mission_duration: the mission duration to modify
@param district_type: the type of the district
"""
func mission_duration_modification(mission_duration: int, district_type: Enums.DistrictType) -> int:
	var modified_mission_duration: int = mission_duration

	if district_type == Enums.DistrictType.PORT:
		modified_mission_duration += PORT_DISTRICT_MODIFIER_BASE
	elif port_bonus_active and district_type == Enums.DistrictType.PORT:
		modified_mission_duration = floor(modified_mission_duration * PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE)

	return modified_mission_duration