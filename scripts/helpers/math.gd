# math_helpers.gd
extends Object

## Mathematical helper functions for stats and random number generation
class_name MathHelpers

## Calculates success chance using a bounded sigmoid function and performs a random check
## [param stat] The input stat value to check against
## [param detailed] Whether to return detailed calculation info or just success boolean
## [param bottom_bound] Minimum possible success chance (default: 20.0)
## [param upper_bound] Maximum possible success chance (default: 80.0)
## [returns] Boolean success result, or Dictionary with detailed calculation info if detailed=true
static func bounded_sigmoid_check(stat: int, detailed: bool = false, bottom_bound: float = 20.0, upper_bound: float = 80.0) -> Variant:
	# Calculate the sigmoid-based success chance
	var k = 1.0  # Steepness of the curve
	var m = 5.0  # Midpoint of the curve
	var raw_chance = 100 / (1 + exp(-k * (stat - m)))
	
	# Scale the raw chance to fit within the bottom and upper bounds
	var success_chance = bottom_bound + (upper_bound - bottom_bound) * (raw_chance / 100)
	
	# Roll a random number between 0 and 100
	var roll = randf() * 100
	
	# Determine success
	var is_success = roll < success_chance
	
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

## Generates a random integer using linear distribution
## [param min] Minimum possible value
## [param max] Maximum possible value
## [returns] Random integer between min and max
static func generateLinearStat(min:int, max:int) -> int:
	return randi() % max + min 

## Generates a random integer using approximate bell curve distribution
## Uses 3d4-2 dice roll method
## [returns] Random integer between 1 and 10
static func generateBellCurveStat() -> int:
	var total = 0
	for i in range(3):
		total += randi() % 4 + 1
	return total - 2