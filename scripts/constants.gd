extends Node

class_name Constants


#|==============================|
#|    Game Initialization       |
#|==============================|
"""
@brief Initial maximum number of agents that can be recruited
"""
const INIT_MAX_AGENTS: int = 2

#|==============================|
#|    Character Initialization  |
#|==============================|
"""
@brief Minimum initial sympathy value for new characters
"""
const CHARACTER_INIT_SYMPATHY_MIN: int 		= 10

"""
@brief Maximum initial sympathy value for new characters
"""
const CHARACTER_INIT_SYMPATHY_MAX: int 		= 30

"""
@brief Minimum initial charm stat for new characters
"""
const CHARACTER_INIT_CHARM_MIN: int 			= 1

"""
@brief Maximum initial charm stat for new characters
"""
const CHARACTER_INIT_CHARM_MAX: int 			= 10

"""
@brief Minimum initial subtlety stat for new characters
"""
const CHARACTER_INIT_SUBTLETY_MIN: int 		= 1

"""
@brief Maximum initial subtlety stat for new characters
"""
const CHARACTER_INIT_SUBTLETY_MAX: int 		= 10

"""
@brief Minimum initial smarts stat for new characters
"""
const CHARACTER_INIT_SMARTS_MIN: int 			= 1

"""
@brief Maximum initial smarts stat for new characters
"""
const CHARACTER_INIT_SMARTS_MAX: int 			= 10

#|==============================|
#|    Rumour Initialization    |
#|==============================|
"""
@brief Number of turns to wait before a rumour expires
"""
const RUMOUR_EXPIRY_TURNS: int = 3

#|==============================|
#|    District Initialization   |
#|==============================|
"""
@brief Minimum initial heat value for new districts
"""
const DISTRICT_INIT_HEAT_MIN: int = 10

"""
@brief Maximum initial heat value for new districts
"""
const DISTRICT_INIT_HEAT_MAX: int = 30

"""
@brief Minimum amount of heat decreased from a district per turn
"""
const DISTRICT_HEAT_DECREASE_PER_TURN_MIN: int = 5

"""
@brief Maximum amount of heat decreased from a district per turn
"""
const DISTRICT_HEAT_DECREASE_PER_TURN_MAX: int = 10

#|==============================|
#|    Action Effects   |
#|==============================|
"""
@brief Amount of heat added to a district when an action fails
"""
const ACTION_EFFECT_FAILED_SUBTLETY: float = 10.0

const FAILURE_CONSEQUENCE_NONE: float = 0.7
const FAILURE_CONSEQUENCE_MIA: float = 0.15
const FAILURE_CONSEQUENCE_INCARCERATED: float = 0.1
const FAILURE_CONSEQUENCE_DECEASED: float = 0.05

const FAILURE_HEAT_MOD_MIA = 0.2
const FAILURE_HEAT_MOD_INCARCERATED = 0.2
const FAILURE_HEAT_MOD_DECEASED = 0.2


"""
@brief Amount of sympathy added to a character when an action is completed
"""
const ACTION_EFFECT_PROPAGANDA_SYMPATHY_MODIFIER: int = 20

"""
@brief Amount of sympathy added to a character when executing BUILD_SYMPATHY plans
"""
const ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MODIFIER: int = 40

"""
@brief Amount of sympathy added to all characters in a district when executing BUILD_SYMPATHY_ALL plans
"""
const ACTION_EFFECT_PLAN_BUILD_SYMPATHY_ALL_MODIFIER: int = 10

"""
@brief Amount of heat reduced from a district when executing REDUCE_HEAT plans
"""
const ACTION_EFFECT_PLAN_REDUCE_HEAT_MODIFIER: int = 20

"""
@brief Amount of heat reduced from all districts when executing REDUCE_HEAT_ALL plans
"""
const ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MODIFIER: int = 10

"""
@brief Percentage increase in difficulty when executing INCREASE_DIFFICULTY plans
"""
const ACTION_EFFECT_PLAN_INCREASE_DIFFICULTY_MODIFIER: int = 10

"""
@brief Percentage decrease in difficulty when executing REDUCE_DIFFICULTY plans
"""
const ACTION_EFFECT_PLAN_REDUCE_DIFFICULTY_MODIFIER: int = 10