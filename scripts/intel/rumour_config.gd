extends Object
class_name RumourConfig

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Percentage chance of generating a mission rumour
"""
var mission_chance: int

"""
@brief Percentage chance of generating a location rumour
"""
var location_chance: int

"""
@brief Percentage chance of generating a time rumour
"""
var time_chance: int

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Initializes the rumour configuration with specified chances.
Scales the chances to ensure they total 100%.

@param mission_chance_arg Chance of generating a mission rumour (default: 33)
@param location_chance_arg Chance of generating a location rumour (default: 33)
@param time_chance_arg Chance of generating a time rumour (default: 34)
"""
func _init(mission_chance_arg: int = 33, location_chance_arg: int = 33, time_chance_arg: int = 34):
	# Scale the chances to ensure they total 100%
	var total = mission_chance_arg + location_chance_arg + time_chance_arg
	mission_chance = (mission_chance_arg * 100) / total
	location_chance = (location_chance_arg * 100) / total
	time_chance = (time_chance_arg * 100) / total
