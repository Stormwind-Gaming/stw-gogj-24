extends Node

var config: ConfigLoader


#|==============================|
#|    Game Initialization       |
#|==============================|
"""
@brief Initial maximum number of agents that can be recruited
"""
var INIT_MAX_AGENTS: int = 2

"""
@brief Heat threshold for triggering the heat endgame
"""
var HEAT_ENDGAME_THRESHOLD: int = 40

"""
@brief Resistance threshold for triggering the resistance endgame
"""
var RESISTANCE_ENDGAME_THRESHOLD: int = 40

#|==============================|
#|    Character Initialization  |
#|==============================|
"""
@brief Minimum initial sympathy value for new characters
"""
var CHARACTER_INIT_SYMPATHY_MIN: int = 10

"""
@brief Maximum initial sympathy value for new characters
"""
var CHARACTER_INIT_SYMPATHY_MAX: int = 30

"""
@brief Minimum initial charm stat for new characters
"""
var CHARACTER_INIT_CHARM_MIN: int = 1

"""
@brief Maximum initial charm stat for new characters
"""
var CHARACTER_INIT_CHARM_MAX: int = 10

"""
@brief Minimum initial subtlety stat for new characters
"""
var CHARACTER_INIT_SUBTLETY_MIN: int = 1

"""
@brief Maximum initial subtlety stat for new characters
"""
var CHARACTER_INIT_SUBTLETY_MAX: int = 10

"""
@brief Minimum initial smarts stat for new characters
"""
var CHARACTER_INIT_SMARTS_MIN: int = 1

"""
@brief Maximum initial smarts stat for new characters
"""
var CHARACTER_INIT_SMARTS_MAX: int = 10

#|==============================|
#|    Rumour Initialization    |
#|==============================|
"""
@brief Number of turns to wait before a rumour expires
"""
var RUMOUR_EXPIRY_TURNS: int = 3

#|==============================|
#|    District Initialization   |
#|==============================|
"""
@brief Minimum initial heat value for new districts
"""
var DISTRICT_INIT_HEAT_MIN: int = 39

"""
@brief Maximum initial heat value for new districts
"""
var DISTRICT_INIT_HEAT_MAX: int = 30

"""
@brief Minimum amount of heat decreased from a district per turn
"""
var DISTRICT_HEAT_DECREASE_PER_TURN_MIN: int = 0

"""
@brief Maximum amount of heat decreased from a district per turn
"""
var DISTRICT_HEAT_DECREASE_PER_TURN_MAX: int = 0

#|==============================|
#|    Action Effects   |
#|==============================|
"""
@brief Minimum amount of heat added to a district when an action fails
"""
var ACTION_EFFECT_FAILED_SUBTLETY_MIN: int = 2

"""
@brief Maximum amount of heat added to a district when an action fails
"""
var ACTION_EFFECT_FAILED_SUBTLETY_MAX: int = 4

"""
@brief Minimum amount of heat added to a district when an action succeeds
"""
var ACTION_EFFECT_SUCCESS_SUBTLETY_MIN: int = 1

"""
@brief Maximum amount of heat added to a district when an action succeeds
"""
var ACTION_EFFECT_SUCCESS_SUBTLETY_MAX: int = 2

"""
@brief Minimum amount of sympathy added to a character when a propaganda action is completed
"""
var ACTION_EFFECT_PROPAGANDA_SYMPATHY_MIN: int = 10

"""
@brief Maximum amount of sympathy added to a character when a propaganda action is completed
"""
var ACTION_EFFECT_PROPAGANDA_SYMPATHY_MAX: int = 20

"""
@brief Minimum amount of sympathy added to a character when executing BUILD_SYMPATHY plans
"""
var ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MIN: int = 35

"""
@brief Maximum amount of sympathy added to a character when executing BUILD_SYMPATHY plans
"""
var ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MAX: int = 45

"""
@brief Minimum amount of sympathy added to all characters in a district when executing BUILD_SYMPATHY_ALL plans
"""
var ACTION_EFFECT_PLAN_BUILD_SYMPATHY_ALL_MIN: int = 8

"""
@brief Maximum amount of sympathy added to all characters in a district when executing BUILD_SYMPATHY_ALL plans
"""
var ACTION_EFFECT_PLAN_BUILD_SYMPATHY_ALL_MAX: int = 12

"""
@brief Minimum amount of heat reduced from a district when executing REDUCE_HEAT plans
"""
var ACTION_EFFECT_PLAN_REDUCE_HEAT_MIN: int = 15

"""
@brief Maximum amount of heat reduced from a district when executing REDUCE_HEAT plans
"""
var ACTION_EFFECT_PLAN_REDUCE_HEAT_MAX: int = 25

"""
@brief Minimum amount of heat reduced from all districts when executing REDUCE_HEAT_ALL plans
"""
var ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MIN: int = 8

"""
@brief Maximum amount of heat reduced from all districts when executing REDUCE_HEAT_ALL plans
"""
var ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MAX: int = 12

"""
@brief Percentage increase in difficulty when executing INCREASE_DIFFICULTY plans
"""
var ACTION_EFFECT_PLAN_INCREASE_DIFFICULTY_MODIFIER: int = 10

"""
@brief Percentage decrease in difficulty when executing REDUCE_DIFFICULTY plans
"""
var ACTION_EFFECT_PLAN_REDUCE_DIFFICULTY_MODIFIER: int = 10

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

var FAILURE_CONSEQUENCE_NONE: float = 0.85
var FAILURE_CONSEQUENCE_MIA: float = 0.1
var FAILURE_CONSEQUENCE_DECEASED: float = 0.05

var FAILURE_HEAT_MOD_NONE: float = 0.5
var FAILURE_HEAT_MOD_MIA: float = 0.1
var FAILURE_HEAT_MOD_DECEASED: float = 0.1

#|==============================|
#| Military District Modifiers	|
#|==============================|

"""
@brief negative effect of performing an action in a military district
"""
# -50% sympathy generated
var MILITARY_DISTRICT_MODIFIER_BASE: float = 0.5
# const MILITARY_DISTRICT_MODIFIER_STAT: sympathy

"""
@brief positive effect gained from military district when over 66 percent sympathy
"""
var MILITARY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE: int = 1
var MILITARY_DISTRICT_MODIFIER_HIGH_SYMPATHY_STAT: Enums.StatCheckType = Enums.StatCheckType.SUBTLETY

#|==============================|
#|   Civic District Modifiers  	|
#|==============================|

"""
@brief negative effect of performing an action in a civic district
"""
# +25% heat generated
var CIVIC_DISTRICT_MODIFIER_BASE: float = 1.25
# const CIVIC_DISTRICT_MODIFIER_STAT: heat

"""
@brief positive effect gained from civic district when over 66 percent sympathy
"""
var CIVIC_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE: int = 1
var CIVIC_DISTRICT_MODIFIER_HIGH_SYMPATHY_STAT: Enums.StatCheckType = Enums.StatCheckType.CHARM

#|==============================|
#| Industry District Modifiers	|
#|==============================|

"""
@brief negative effect of performing an action in an industry district
"""
# +10% injury risk
var INDUSTRY_DISTRICT_MODIFIER_BASE: float = 1.1
# const INDUSTRY_DISTRICT_MODIFIER_STAT: injury

"""
@brief positive effect gained from industry district when over 66 percent sympathy
"""
var INDUSTRY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE: int = 1
var INDUSTRY_DISTRICT_MODIFIER_HIGH_SYMPATHY_STAT: Enums.StatCheckType = Enums.StatCheckType.SMARTS

#|==============================|
#|Residential District Modifiers|
#|==============================|

"""
@brief negative effect of performing an action in a residential district
"""
# +10% subtlety check failure risk
var RESIDENTIAL_DISTRICT_MODIFIER_BASE: float = 1.1
# const RESIDENTIAL_DISTRICT_MODIFIER_STAT: subtlety check

"""
@brief positive effect gained from residential district when over 66 percent sympathy
"""
var RESIDENTIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE: float = 1.25
# const RESIDENTIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_STAT: sympathy

#|==============================|
#|	Port District Modifiers			|
#|==============================|

"""
@brief negative effect of performing an action in a port district
"""
# +1 mission duration
var PORT_DISTRICT_MODIFIER_BASE: int = 1
# const PORT_DISTRICT_MODIFIER_STAT: mission duration

"""
@brief positive effect gained from port district when over 66 percent sympathy
"""
var PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE: float = 0.75
# const PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_STAT: heat

#|==============================|
#|    World Event Settings     |
#|==============================|

"""
@brief Minimum chance bounding (%) for a world event check to trigger
Used in sigmoid probability calculation for event occurrence
"""
var WORLD_EVENT_CHECK_MIN_CHANCE: float = 10.0

"""
@brief Maximum chance bounding (%) for a world event check to trigger
Used in sigmoid probability calculation for event occurrence
"""
var WORLD_EVENT_CHECK_MAX_CHANCE: float = 90.0

"""
@brief Heat threshold for considering the world "high heat" (>=70)
Affects world event severity probabilities
"""
var HIGH_HEAT_THRESHOLD: int = 70

"""
@brief Heat threshold for considering the world "medium heat" (>=35)
Affects world event severity probabilities
"""
var MEDIUM_HEAT_THRESHOLD: int = 35

"""
@brief Chance (%) of getting a minor event in high heat situations
In high heat: 20% minor, 40% significant, 40% major
"""
var HIGH_HEAT_MINOR_CHANCE: float = 0.2

"""
@brief Chance threshold (%) for significant events in high heat
Values below this are minor (20%), values between this and 100% are split
between significant (40%) and major (40%)
"""
var HIGH_HEAT_SIGNIFICANT_CHANCE: float = 0.6

"""
@brief Chance (0-1.0) of getting a minor event in medium heat
In medium heat: 40% minor, 60% significant
"""
var MEDIUM_HEAT_MINOR_CHANCE: float = 0.4

#|==============================|
#|    Stat Check Bounds        |
#|==============================|

"""
@brief Minimum possible success chance for subtlety checks (%)
"""
var SUBTLETY_CHECK_MIN_CHANCE: float = 20.0

"""
@brief Maximum possible success chance for subtlety checks (%)
"""
var SUBTLETY_CHECK_MAX_CHANCE: float = 80.0

"""
@brief Minimum possible success chance for smarts checks (%)
"""
var SMARTS_CHECK_MIN_CHANCE: float = 20.0

"""
@brief Maximum possible success chance for smarts checks (%)
"""
var SMARTS_CHECK_MAX_CHANCE: float = 80.0

"""
@brief Minimum possible success chance for charm checks (%)
"""
var CHARM_CHECK_MIN_CHANCE: float = 20.0

"""
@brief Maximum possible success chance for charm checks (%)
"""
var CHARM_CHECK_MAX_CHANCE: float = 80.0

func _ready():
	config = ConfigLoader.new()
	add_child(config)
	config.connect("constants_loaded", _on_constants_loaded)

func _on_constants_loaded():
	print('constants loaded', config._values)
	print(config.get_value("INIT_MAX_AGENTS"))

	# Game Initialization
	INIT_MAX_AGENTS = config.get_value("INIT_MAX_AGENTS", INIT_MAX_AGENTS)
	HEAT_ENDGAME_THRESHOLD = config.get_value("HEAT_ENDGAME_THRESHOLD", HEAT_ENDGAME_THRESHOLD)
	RESISTANCE_ENDGAME_THRESHOLD = config.get_value("RESISTANCE_ENDGAME_THRESHOLD", RESISTANCE_ENDGAME_THRESHOLD)
	
	# Character Initialization
	CHARACTER_INIT_SYMPATHY_MIN = config.get_value("CHARACTER_INIT_SYMPATHY_MIN", CHARACTER_INIT_SYMPATHY_MIN)
	CHARACTER_INIT_SYMPATHY_MAX = config.get_value("CHARACTER_INIT_SYMPATHY_MAX", CHARACTER_INIT_SYMPATHY_MAX)
	CHARACTER_INIT_CHARM_MIN = config.get_value("CHARACTER_INIT_CHARM_MIN", CHARACTER_INIT_CHARM_MIN)
	CHARACTER_INIT_CHARM_MAX = config.get_value("CHARACTER_INIT_CHARM_MAX", CHARACTER_INIT_CHARM_MAX)
	CHARACTER_INIT_SUBTLETY_MIN = config.get_value("CHARACTER_INIT_SUBTLETY_MIN", CHARACTER_INIT_SUBTLETY_MIN)
	CHARACTER_INIT_SUBTLETY_MAX = config.get_value("CHARACTER_INIT_SUBTLETY_MAX", CHARACTER_INIT_SUBTLETY_MAX)
	CHARACTER_INIT_SMARTS_MIN = config.get_value("CHARACTER_INIT_SMARTS_MIN", CHARACTER_INIT_SMARTS_MIN)
	CHARACTER_INIT_SMARTS_MAX = config.get_value("CHARACTER_INIT_SMARTS_MAX", CHARACTER_INIT_SMARTS_MAX)
	
	# Rumour Initialization
	RUMOUR_EXPIRY_TURNS = config.get_value("RUMOUR_EXPIRY_TURNS", RUMOUR_EXPIRY_TURNS)
	
	# District Initialization
	DISTRICT_INIT_HEAT_MIN = config.get_value("DISTRICT_INIT_HEAT_MIN", DISTRICT_INIT_HEAT_MIN)
	DISTRICT_INIT_HEAT_MAX = config.get_value("DISTRICT_INIT_HEAT_MAX", DISTRICT_INIT_HEAT_MAX)
	DISTRICT_HEAT_DECREASE_PER_TURN_MIN = config.get_value("DISTRICT_HEAT_DECREASE_PER_TURN_MIN", DISTRICT_HEAT_DECREASE_PER_TURN_MIN)
	DISTRICT_HEAT_DECREASE_PER_TURN_MAX = config.get_value("DISTRICT_HEAT_DECREASE_PER_TURN_MAX", DISTRICT_HEAT_DECREASE_PER_TURN_MAX)
	
	# Action Effects
	ACTION_EFFECT_FAILED_SUBTLETY_MIN = config.get_value("ACTION_EFFECT_FAILED_SUBTLETY_MIN", ACTION_EFFECT_FAILED_SUBTLETY_MIN)
	ACTION_EFFECT_FAILED_SUBTLETY_MAX = config.get_value("ACTION_EFFECT_FAILED_SUBTLETY_MAX", ACTION_EFFECT_FAILED_SUBTLETY_MAX)
	ACTION_EFFECT_SUCCESS_SUBTLETY_MIN = config.get_value("ACTION_EFFECT_SUCCESS_SUBTLETY_MIN", ACTION_EFFECT_SUCCESS_SUBTLETY_MIN)
	ACTION_EFFECT_SUCCESS_SUBTLETY_MAX = config.get_value("ACTION_EFFECT_SUCCESS_SUBTLETY_MAX", ACTION_EFFECT_SUCCESS_SUBTLETY_MAX)
	ACTION_EFFECT_PROPAGANDA_SYMPATHY_MIN = config.get_value("ACTION_EFFECT_PROPAGANDA_SYMPATHY_MIN", ACTION_EFFECT_PROPAGANDA_SYMPATHY_MIN)
	ACTION_EFFECT_PROPAGANDA_SYMPATHY_MAX = config.get_value("ACTION_EFFECT_PROPAGANDA_SYMPATHY_MAX", ACTION_EFFECT_PROPAGANDA_SYMPATHY_MAX)
	ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MIN = config.get_value("ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MIN", ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MIN)
	ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MAX = config.get_value("ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MAX", ACTION_EFFECT_PLAN_BUILD_SYMPATHY_MAX)
	ACTION_EFFECT_PLAN_REDUCE_HEAT_MIN = config.get_value("ACTION_EFFECT_PLAN_REDUCE_HEAT_MIN", ACTION_EFFECT_PLAN_REDUCE_HEAT_MIN)
	ACTION_EFFECT_PLAN_REDUCE_HEAT_MAX = config.get_value("ACTION_EFFECT_PLAN_REDUCE_HEAT_MAX", ACTION_EFFECT_PLAN_REDUCE_HEAT_MAX)
	ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MIN = config.get_value("ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MIN", ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MIN)
	ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MAX = config.get_value("ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MAX", ACTION_EFFECT_PLAN_REDUCE_HEAT_ALL_MAX)
	ACTION_EFFECT_PLAN_INCREASE_DIFFICULTY_MODIFIER = config.get_value("ACTION_EFFECT_PLAN_INCREASE_DIFFICULTY_MODIFIER", ACTION_EFFECT_PLAN_INCREASE_DIFFICULTY_MODIFIER)
	ACTION_EFFECT_PLAN_REDUCE_DIFFICULTY_MODIFIER = config.get_value("ACTION_EFFECT_PLAN_REDUCE_DIFFICULTY_MODIFIER", ACTION_EFFECT_PLAN_REDUCE_DIFFICULTY_MODIFIER)
	
	# Consequence Modifiers
	FAILURE_CONSEQUENCE_NONE = config.get_value("FAILURE_CONSEQUENCE_NONE", FAILURE_CONSEQUENCE_NONE)
	FAILURE_CONSEQUENCE_MIA = config.get_value("FAILURE_CONSEQUENCE_MIA", FAILURE_CONSEQUENCE_MIA)
	FAILURE_CONSEQUENCE_DECEASED = config.get_value("FAILURE_CONSEQUENCE_DECEASED", FAILURE_CONSEQUENCE_DECEASED)
	FAILURE_HEAT_MOD_NONE = config.get_value("FAILURE_HEAT_MOD_NONE", FAILURE_HEAT_MOD_NONE)
	FAILURE_HEAT_MOD_MIA = config.get_value("FAILURE_HEAT_MOD_MIA", FAILURE_HEAT_MOD_MIA)
	FAILURE_HEAT_MOD_DECEASED = config.get_value("FAILURE_HEAT_MOD_DECEASED", FAILURE_HEAT_MOD_DECEASED)
	
	# District Modifiers
	MILITARY_DISTRICT_MODIFIER_BASE = config.get_value("MILITARY_DISTRICT_MODIFIER_BASE", MILITARY_DISTRICT_MODIFIER_BASE)
	MILITARY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE = config.get_value("MILITARY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE", MILITARY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE)
	CIVIC_DISTRICT_MODIFIER_BASE = config.get_value("CIVIC_DISTRICT_MODIFIER_BASE", CIVIC_DISTRICT_MODIFIER_BASE)
	CIVIC_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE = config.get_value("CIVIC_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE", CIVIC_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE)
	INDUSTRY_DISTRICT_MODIFIER_BASE = config.get_value("INDUSTRY_DISTRICT_MODIFIER_BASE", INDUSTRY_DISTRICT_MODIFIER_BASE)
	INDUSTRY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE = config.get_value("INDUSTRY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE", INDUSTRY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE)
	RESIDENTIAL_DISTRICT_MODIFIER_BASE = config.get_value("RESIDENTIAL_DISTRICT_MODIFIER_BASE", RESIDENTIAL_DISTRICT_MODIFIER_BASE)
	RESIDENTIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE = config.get_value("RESIDENTIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE", RESIDENTIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE)
	PORT_DISTRICT_MODIFIER_BASE = config.get_value("PORT_DISTRICT_MODIFIER_BASE", PORT_DISTRICT_MODIFIER_BASE)
	PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE = config.get_value("PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE", PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE)
	
	# World Event Settings
	WORLD_EVENT_CHECK_MIN_CHANCE = config.get_value("WORLD_EVENT_CHECK_MIN_CHANCE", WORLD_EVENT_CHECK_MIN_CHANCE)
	WORLD_EVENT_CHECK_MAX_CHANCE = config.get_value("WORLD_EVENT_CHECK_MAX_CHANCE", WORLD_EVENT_CHECK_MAX_CHANCE)
	HIGH_HEAT_THRESHOLD = config.get_value("HIGH_HEAT_THRESHOLD", HIGH_HEAT_THRESHOLD)
	MEDIUM_HEAT_THRESHOLD = config.get_value("MEDIUM_HEAT_THRESHOLD", MEDIUM_HEAT_THRESHOLD)
	HIGH_HEAT_MINOR_CHANCE = config.get_value("HIGH_HEAT_MINOR_CHANCE", HIGH_HEAT_MINOR_CHANCE)
	HIGH_HEAT_SIGNIFICANT_CHANCE = config.get_value("HIGH_HEAT_SIGNIFICANT_CHANCE", HIGH_HEAT_SIGNIFICANT_CHANCE)
	MEDIUM_HEAT_MINOR_CHANCE = config.get_value("MEDIUM_HEAT_MINOR_CHANCE", MEDIUM_HEAT_MINOR_CHANCE)

	# Stat Check Bounds
	SUBTLETY_CHECK_MIN_CHANCE = config.get_value("SUBTLETY_CHECK_MIN_CHANCE", SUBTLETY_CHECK_MIN_CHANCE)
	SUBTLETY_CHECK_MAX_CHANCE = config.get_value("SUBTLETY_CHECK_MAX_CHANCE", SUBTLETY_CHECK_MAX_CHANCE)
	SMARTS_CHECK_MIN_CHANCE = config.get_value("SMARTS_CHECK_MIN_CHANCE", SMARTS_CHECK_MIN_CHANCE)
	SMARTS_CHECK_MAX_CHANCE = config.get_value("SMARTS_CHECK_MAX_CHANCE", SMARTS_CHECK_MAX_CHANCE)
	CHARM_CHECK_MIN_CHANCE = config.get_value("CHARM_CHECK_MIN_CHANCE", CHARM_CHECK_MIN_CHANCE)
	CHARM_CHECK_MAX_CHANCE = config.get_value("CHARM_CHECK_MAX_CHANCE", CHARM_CHECK_MAX_CHANCE)
