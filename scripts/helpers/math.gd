# math_helpers.gd
extends ObjectWithCleanup

## Mathematical helper functions for stats and random number generation
class_name MathHelpers

#|==============================|
#|      Success Checks         |
#|==============================|
"""
@brief Calculates success chance using a bounded sigmoid function and performs a random check.

@param stat The input stat value to check against
@param detailed Whether to return detailed calculation info or just success boolean
@param bottom_bound Minimum possible success chance (default: 20.0)
@param upper_bound Maximum possible success chance (default: 80.0)
@returns Boolean success result, or Dictionary with detailed calculation info if detailed=true
"""
static func bounded_sigmoid_check(stat: int, detailed: bool = false, bottom_bound: float = 20.0, upper_bound: float = 80.0) -> Variant:
	LogDuck.d("Starting bounded sigmoid check", {
		"stat": stat,
		"detailed": detailed,
		"bottom_bound": bottom_bound,
		"upper_bound": upper_bound
	})
	
	var k = 1.0 # Steepness of the curve
	var m = 5.0 # Midpoint of the curve
	var raw_chance = 100 / (1 + exp(-k * (stat - m)))
	
	# Scale the raw chance to fit within the bottom and upper bounds
	var success_chance = bottom_bound + (upper_bound - bottom_bound) * (raw_chance / 100)
	
	# Roll a random number between 0 and 100
	var roll = randf() * 100
	
	# Determine success
	var is_success = roll < success_chance
	
	LogDuck.d("Sigmoid check calculation complete", {
		"raw_chance": raw_chance,
		"scaled_chance": success_chance,
		"roll": roll,
		"success": is_success
	})
	
	# Return based on the 'detailed' flag
	if detailed:
		return {
			"success": is_success,
			"stat": stat,
			"raw_chance": raw_chance,
			"success_chance": success_chance,
			"roll": roll
		}
	else:
		return is_success

"""
@brief Calculates success chance using a bounded sigmoid function without performing a roll.

@param stat The input stat value to check against
@param bottom_bound Minimum possible success chance (default: 20.0)
@param upper_bound Maximum possible success chance (default: 80.0)
@returns Float between 0 and 1 representing the probability of success
"""
static func bounded_sigmoid_probability(stat: int, bottom_bound: float = 20.0, upper_bound: float = 80.0) -> float:
	LogDuck.d("Calculating sigmoid probability", {
		"stat": stat,
		"bottom_bound": bottom_bound,
		"upper_bound": upper_bound
	})
	
	var k = 1.0 # Steepness of the curve
	var m = 5.0 # Midpoint of the curve
	var raw_chance = 100 / (1 + exp(-k * (stat - m)))
	
	# Scale the raw chance to fit within the bottom and upper bounds
	var success_chance = bottom_bound + (upper_bound - bottom_bound) * (raw_chance / 100)
	
	var probability = success_chance / 100.0
	
	LogDuck.d("Probability calculation complete", {
		"raw_chance": raw_chance,
		"success_chance": success_chance,
		"final_probability": probability
	})
	
	return probability

#|==============================|
#|      Random Generation      |
#|==============================|
"""
@brief Generates a random integer using linear distribution.

@param min Minimum possible value
@param max Maximum possible value
@returns Random integer between min and max
"""
static func generate_linear_stat(min: int, max: int) -> int:
	var result = randi() % max + min
	LogDuck.d("Generated linear stat", {
		"min": min,
		"max": max,
		"result": result
	})
	return result

"""
@brief Generates a random integer using a bell curve distribution within a specified range.

@param min Minimum possible value (default: 1)
@param max Maximum possible value (default: 10)
@returns Random integer between min and max
"""
static func generate_bell_curve_stat(min: int = 1, max: int = 10) -> int:
	LogDuck.d("Generating bell curve stat", {
		"min": min,
		"max": max
	})
	
	var total = 0
	for i in range(3):
		var roll = randi() % 4 + 1
		total += roll
		LogDuck.d("Bell curve die roll", {
			"roll_number": i + 1,
			"roll_value": roll,
			"running_total": total
		})
	
	total -= 2
	var scaled_value = float(total - 1) / (10 - 1)
	var result = int(round(min + scaled_value * (max - min)))
	
	LogDuck.d("Bell curve stat generated", {
		"raw_total": total,
		"scaled_value": scaled_value,
		"final_result": result
	})
	
	return result

"""
@brief Scales a base value based on a progress value within a given range.
       Useful for scaling chances, rewards, or difficulties based on game progress.

@param base_value The starting value to scale
@param progress The current progress value
@param progress_min The minimum value of the progress range (default: 1)
@param progress_max The maximum value of the progress range (default: 100)
@param scale_min The minimum scaling multiplier (default: 0.5)
@param scale_max The maximum scaling multiplier (default: 1.5)
@param clamp_min Optional minimum value for the result (default: -INF)
@param clamp_max Optional maximum value for the result (default: INF)
@returns The scaled value
"""
static func scale_by_progress(
	base_value: float,
	progress: float,
	progress_min: float = 1.0,
	progress_max: float = 100.0,
	scale_min: float = 0.5,
	scale_max: float = 1.5,
	clamp_min: float = -INF,
	clamp_max: float = INF
) -> float:
	LogDuck.d("Scaling value by progress", {
		"base_value": base_value,
		"progress": progress,
		"progress_range": [progress_min, progress_max],
		"scale_range": [scale_min, scale_max],
		"clamp_range": [clamp_min, clamp_max]
	})
	
	var normalized_progress = (progress - progress_min) / (progress_max - progress_min)
	normalized_progress = clamp(normalized_progress, 0.0, 1.0)
	var scale_multiplier = scale_min + (normalized_progress * (scale_max - scale_min))
	var result = clamp(base_value * scale_multiplier, clamp_min, clamp_max)
	
	LogDuck.d("Progress scaling complete", {
		"normalized_progress": normalized_progress,
		"scale_multiplier": scale_multiplier,
		"final_result": result
	})
	
	return result