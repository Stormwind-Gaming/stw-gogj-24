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
const ACTION_EFFECT_FAILED_SUBTLETY: int = 10

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

#|==============================|
#|    Consequence Modifiers     |
#|==============================|
"""
@brief Base probabilities and heat modifiers for action failure consequences
       All probabilities are normalized to sum to 1.0 (100%) at all heat levels

Base probabilities (sum to 100%):
NONE:     85% (0.85)
MIA:      10% (0.10)
DECEASED:  5% (0.05)

Heat modifies these base probabilities using the formula:
1. Calculate raw probabilities:
   NONE:     base_chance * (1.0 - heat_factor * mod)
   MIA:      base_chance + (heat_factor * mod)
   DECEASED: base_chance + (heat_factor * mod)

2. Normalize by dividing each probability by their sum

Example at 0 heat (heat_factor = 0.0):
NONE:     0.85 / 1.00 = 0.85    (85%)
MIA:      0.10 / 1.00 = 0.10    (10%)
DECEASED: 0.05 / 1.00 = 0.05     (5%)
Total:                  1.00   (100%)

Example at 50 heat (heat_factor = 0.5):
Raw values:
NONE:     0.85 * (1.0 - 0.5 * 0.5) = 0.744
MIA:      0.10 + (0.5 * 0.1)       = 0.150
DECEASED: 0.05 + (0.5 * 0.1)       = 0.100
Total: 0.994

Normalized:
NONE:     0.744 / 0.994 = 0.748   (74.8%)
MIA:      0.150 / 0.994 = 0.151   (15.1%)
DECEASED: 0.100 / 0.994 = 0.101   (10.1%)
Total:                   1.000   (100%)

Example at 100 heat (heat_factor = 1.0):
Raw values:
NONE:     0.85 * (1.0 - 1.0 * 0.5) = 0.425
MIA:      0.10 + (1.0 * 0.1)       = 0.200
DECEASED: 0.05 + (1.0 * 0.1)       = 0.150
Total: 0.775

Normalized:
NONE:     0.425 / 0.775 = 0.548   (54.8%)
MIA:      0.200 / 0.775 = 0.258   (25.8%)
DECEASED: 0.150 / 0.775 = 0.194   (19.4%)
Total:                   1.000   (100%)
"""

const FAILURE_CONSEQUENCE_NONE: float = 0.85
const FAILURE_CONSEQUENCE_MIA: float = 0.1
const FAILURE_CONSEQUENCE_DECEASED: float = 0.05

const FAILURE_HEAT_MOD_NONE: float = 0.5
const FAILURE_HEAT_MOD_MIA: float = 0.1
const FAILURE_HEAT_MOD_DECEASED: float = 0.1

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

