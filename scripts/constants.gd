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