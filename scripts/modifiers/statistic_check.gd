extends Object

class_name StatisticCheck

var characters: Array[Character] = []
var district: District = null
var poi: PointOfInterest = null

var stats: Dictionary = {
	"subtlety": 0,
	"smarts": 0,
	"charm": 0
}

var modifiers: Array = []

func _init(_characters: Array[Character], _district: District, _poi: PointOfInterest) -> void:
	characters = _characters
	district = _district
	poi = _poi

	stats = _get_stats()

	modifiers = _get_all_modifiers()

	print("--- STATISTIC CHECK SETUP ---")
	for modifier in modifiers:
		print("Modifier active: ", modifier.active)
	print("--- END STATISTIC CHECK SETUP ---")

func subtlety_check() -> bool:
	var subtlety_check_value = stats.subtlety
	print("--- SUBTLETY CHECK ---")
	print("Base value: ", subtlety_check_value)

	for modifier in modifiers:
		print("Modifier: ", modifier.modifier_name, " ", subtlety_check_value, " + ", modifier.modifier_subtlety_flat)
		subtlety_check_value += modifier.modifier_subtlety_flat

	# if this is the home PoI of this character, add the home modifier (+25%)
	if poi == characters[0].char_associated_poi:
		print("Home modifier: ", subtlety_check_value, " * 1.25")
		subtlety_check_value *= 1.25
	
	var subtlety_roll = MathHelpers.bounded_sigmoid_check(
		subtlety_check_value,
		true,
		Constants.SUBTLETY_CHECK_MIN_CHANCE,
		Constants.SUBTLETY_CHECK_MAX_CHANCE
	)

	# emit stats change
	EventBus.stat_created.emit("subtlety", subtlety_roll.success)

	print("--- END SUBTLETY CHECK ---")

	return subtlety_roll.success

func smarts_check() -> bool:
	var smarts_check_value = stats.smarts
	print("--- SMARTS CHECK ---")
	print("Base value: ", smarts_check_value)

	for modifier in modifiers:
		print("Modifier: ", modifier.modifier_name, " ", smarts_check_value, " + ", modifier.modifier_smarts_flat)
		smarts_check_value += modifier.modifier_smarts_flat

	var smarts_roll = MathHelpers.bounded_sigmoid_check(
		smarts_check_value,
		true,
		Constants.SMARTS_CHECK_MIN_CHANCE,
		Constants.SMARTS_CHECK_MAX_CHANCE
	)

	print("--- END SMARTS CHECK ---")

	# emit stats change
	EventBus.stat_created.emit("smarts", smarts_roll.success)

	return smarts_roll.success

func charm_check() -> bool:
	var charm_check_value = stats.charm
	print("--- CHARM CHECK ---")
	print("Base value: ", charm_check_value)

	for modifier in modifiers:
		print("Modifier: ", modifier.modifier_name, " ", charm_check_value, " + ", modifier.modifier_charm_flat)
		charm_check_value += modifier.modifier_charm_flat

	var charm_roll = MathHelpers.bounded_sigmoid_check(
		charm_check_value,
		true,
		Constants.CHARM_CHECK_MIN_CHANCE,
		Constants.CHARM_CHECK_MAX_CHANCE
	)

	print("--- END CHARM CHECK ---")

	# emit stats change
	EventBus.stat_created.emit("charm", charm_roll.success)

	return charm_roll.success

func sympathy_added(min_value: int, max_value: int) -> int:
	print("--- SYMPATHY ADDED ---")
	print("Base range: ", min_value, " ", max_value)

	var base_sympathy_added: int = MathHelpers.generate_bell_curve_stat(min_value, max_value)
	print("Base value: ", base_sympathy_added)

	for modifier in modifiers:
		print("Modifier: ", modifier.modifier_name, " ", base_sympathy_added, " * ", modifier.modifier_sympathy_multiplier)
		base_sympathy_added *= modifier.modifier_sympathy_multiplier

	print("--- END SYMPATHY ADDED ---")

	return base_sympathy_added

func heat_added(min_value: int, max_value: int) -> int:
	print("--- HEAT ADDED ---")
	print("Base range: ", min_value, " ", max_value)

	var base_heat_added: int = MathHelpers.generate_bell_curve_stat(min_value, max_value)
	print("Base value: ", base_heat_added)

	for modifier in modifiers:
		print("Modifier: ", modifier.modifier_name, " ", base_heat_added, " * ", modifier.modifier_heat_multiplier)
		base_heat_added *= modifier.modifier_heat_multiplier

	print("--- END HEAT ADDED ---")

	return base_heat_added


func action_duration(base_duration: int) -> int:
	print("--- ACTION DURATION ---")
	print("Base duration: ", base_duration)

	for modifier in modifiers:
		print("Modifier: ", modifier.modifier_name, " ", base_duration, " + ", modifier.modifier_action_duration_flat)
		base_duration += modifier.modifier_action_duration_flat

	for modifier in modifiers:
		print("Modifier: ", modifier.modifier_name, " ", base_duration, " * ", modifier.modifier_action_duration_multiplier)
		base_duration *= modifier.modifier_action_duration_multiplier

	# Reduce the duration by 1 for each additional character to a minimum of 1
	base_duration = max(1, base_duration - (characters.size() - 1))

	print("--- END ACTION DURATION ---")

	return base_duration

func intel_added(base_intel: int) -> int:
	print("--- INTEL ADDED ---")
	print("Base intel: ", base_intel)

	for modifier in modifiers:
		print("Modifier: ", modifier.modifier_name, " ", base_intel, " + ", modifier.modifier_intel_spawn_flat)
		base_intel += modifier.modifier_intel_spawn_flat

	for modifier in modifiers:
		print("Modifier: ", modifier.modifier_name, " ", base_intel, " * ", modifier.modifier_intel_spawn_multiplier)
		base_intel *= modifier.modifier_intel_spawn_multiplier

	print("--- END INTEL ADDED ---")

	return base_intel

func _get_all_modifiers() -> Array:
	return GlobalRegistry.modifiers.get_all_items().filter(func(_modifier: Modifier) -> bool:
		if not _modifier.active:
			return false

		if _modifier.scope == Enums.ModifierScope.DISTRICT:
			return _modifier.district == district
		elif _modifier.scope == Enums.ModifierScope.WORLD:
			return true

		return false
	)

"""
@brief Gets the combined stats of all characters involved in the action.
Calculates the overall performance of the team by combining averages, complementary multipliers, and overspecialization penalties.
"""
func _get_stats() -> Dictionary:
	var _stats: Dictionary = {
		"subtlety": 0,
		"smarts": 0,
		"charm": 0
	}
	
	# Calculate team averages
	var team_averages: Dictionary = _calculate_team_averages()

	if characters.size() == 1:
		return team_averages
	
	# Calculate multipliers
	var complementarity_multiplier: float = _calculate_complementarity_multiplier(team_averages)
	var overspecialization_multiplier: float = _calculate_overspecialization_multiplier()
	
	# Apply multipliers and clamp final stats
	for stat in _stats.keys():
		var base_stat: float = team_averages[stat]
		var final_stat: float = base_stat * complementarity_multiplier * overspecialization_multiplier
		_stats[stat] = clamp(int(round(final_stat)), 1, 10)

	return _stats

"""
@brief Calculates the average values of each stat across the team.
@return A dictionary containing the average stats for "subtlety", "smarts", and "charm".
"""
func _calculate_team_averages() -> Dictionary:
	var total_subtlety: float = 0
	var total_smarts: float = 0
	var total_charm: float = 0
	var num_characters: int = characters.size()
	
	for character in characters:
		total_subtlety += character.char_subtlety
		total_smarts += character.char_smarts
		total_charm += character.char_charm
	
	return {
		"subtlety": total_subtlety / num_characters,
		"smarts": total_smarts / num_characters,
		"charm": total_charm / num_characters
	}

"""
@brief Rewards complementary stats by reducing the difference between the highest and lowest team averages.
@param team_averages A dictionary containing the average stats for "subtlety", "smarts", and "charm".
@return A float multiplier for complementarity (e.g., 1.0 for no bonus, up to 1.2 for maximum bonus in small teams).
"""
func _calculate_complementarity_multiplier(team_averages: Dictionary) -> float:
	var stat_values: Array = [
		team_averages["subtlety"],
		team_averages["smarts"],
		team_averages["charm"]
	]
	var stat_range: float = stat_values.max() - stat_values.min()
	
	# Scale maximum bonus based on team size (e.g., 20% for 2 characters, 10% for 5 characters)
	var max_bonus: float = 20.0 - (characters.size() - 2) * 2.5
	max_bonus = max(10.0, max_bonus) # Ensure max bonus doesn't go below 10%
	
	# Bonus decreases as range increases; capped at scaled maximum
	var bonus_percentage: float = max(0, max_bonus - stat_range)
	return 1 + (bonus_percentage / 100)


"""
@brief Penalizes overspecialization by applying penalties for redundant high stats in the team.
@return A float multiplier for overspecialization (e.g., 1.0 for no penalty, 0.9 for 10% penalty).
"""
func _calculate_overspecialization_multiplier() -> float:
	var penalty_percentage: float = 0
	var threshold: int = 8 # Stats above this value are considered "high"
	
	for stat in ["char_subtlety", "char_smarts", "char_charm"]:
		# Count how many characters exceed the threshold in this stat
		var high_stat_count: int = 0
		for character in characters:
			if character.get(stat) > threshold:
				high_stat_count += 1
		
		# Penalize any high stat counts that exceed half the team size
		var allowed_high_stats: int = characters.size() / 2
		if high_stat_count > allowed_high_stats:
			penalty_percentage += (high_stat_count - allowed_high_stats) * 5 # 5% penalty per excess stat
	
	return max(0.5, 1 - (penalty_percentage / 100)) # Minimum multiplier of 0.5


func get_subtlety_chance() -> float:
	var subtlety_check_value = stats.subtlety
	
	for modifier in modifiers:
		subtlety_check_value += modifier.modifier_subtlety_flat
	
	# if this is the home PoI of this character, add the home modifier (+25%)
	if poi == characters[0].char_associated_poi:
		subtlety_check_value *= 1.25
	
	return MathHelpers.bounded_sigmoid_probability(
		subtlety_check_value,
		Constants.SUBTLETY_CHECK_MIN_CHANCE,
		Constants.SUBTLETY_CHECK_MAX_CHANCE
	)

func get_smarts_chance() -> float:
	var smarts_check_value = stats.smarts
	
	for modifier in modifiers:
		smarts_check_value += modifier.modifier_smarts_flat
	
	return MathHelpers.bounded_sigmoid_probability(
		smarts_check_value,
		Constants.SMARTS_CHECK_MIN_CHANCE,
		Constants.SMARTS_CHECK_MAX_CHANCE
	)

func get_charm_chance() -> float:
	var charm_check_value = stats.charm
	
	for modifier in modifiers:
		charm_check_value += modifier.modifier_charm_flat
	
	return MathHelpers.bounded_sigmoid_probability(
		charm_check_value,
		Constants.CHARM_CHECK_MIN_CHANCE,
		Constants.CHARM_CHECK_MAX_CHANCE
	)

func get_team_modifiers() -> Dictionary:
	# Calculate team averages first since we need them for complementarity
	var team_averages: Dictionary = _calculate_team_averages()
	
	# Get the multipliers
	var complementarity: float = _calculate_complementarity_multiplier(team_averages)
	var overspecialization: float = _calculate_overspecialization_multiplier()
	
	# Calculate the actual stat changes
	var comp_changes := {
		"subtlety": int(round(team_averages.subtlety * complementarity)) - int(round(team_averages.subtlety)),
		"smarts": int(round(team_averages.smarts * complementarity)) - int(round(team_averages.smarts)),
		"charm": int(round(team_averages.charm * complementarity)) - int(round(team_averages.charm))
	}
	
	var overspec_changes := {
		"subtlety": int(round(team_averages.subtlety * overspecialization)) - int(round(team_averages.subtlety)),
		"smarts": int(round(team_averages.smarts * overspecialization)) - int(round(team_averages.smarts)),
		"charm": int(round(team_averages.charm * overspecialization)) - int(round(team_averages.charm))
	}
	
	return {
		"complementarity": {
			"multiplier": complementarity,
			"effect": str(round((complementarity - 1.0) * 100)) + "%",
			"stat_changes": comp_changes
		},
		"overspecialization": {
			"multiplier": overspecialization,
			"effect": str(round((overspecialization - 1.0) * 100)) + "%",
			"stat_changes": overspec_changes
		}
	}

"""
@brief Calculates the consequence probabilities taking into account all active modifiers
@param district_heat The current heat level of the district
@return Dictionary containing the modified probabilities for each consequence type
"""
func get_consequence_probabilities(district_heat: int) -> Dictionary:
	var heat_factor = district_heat / 100.0
	
	# Calculate raw probabilities
	var raw_chances = {
		Enums.CharacterState.ASSIGNED: Constants.FAILURE_CONSEQUENCE_NONE,
		Enums.CharacterState.INJURED: Constants.FAILURE_CONSEQUENCE_INJURED,
		Enums.CharacterState.MIA: Constants.FAILURE_CONSEQUENCE_MIA,
		Enums.CharacterState.DECEASED: Constants.FAILURE_CONSEQUENCE_DECEASED
	}
	
	# Calculate heat-modified probabilities
	var modified_chances = {
		Enums.CharacterState.ASSIGNED: raw_chances[Enums.CharacterState.ASSIGNED] * (1.0 - heat_factor * Constants.FAILURE_HEAT_MOD_NONE),
		Enums.CharacterState.INJURED: raw_chances[Enums.CharacterState.INJURED] + (heat_factor * Constants.FAILURE_HEAT_MOD_INJURED),
		Enums.CharacterState.MIA: raw_chances[Enums.CharacterState.MIA] + (heat_factor * Constants.FAILURE_HEAT_MOD_MIA),
		Enums.CharacterState.DECEASED: raw_chances[Enums.CharacterState.DECEASED] + (heat_factor * Constants.FAILURE_HEAT_MOD_DECEASED)
	}
	
	# Apply modifier effects to all negative consequences
	for modifier in modifiers:
		if modifier.modifier_consequence_multiplier != 1.0:
			modified_chances[Enums.CharacterState.INJURED] *= modifier.modifier_consequence_multiplier
			modified_chances[Enums.CharacterState.MIA] *= modifier.modifier_consequence_multiplier
			modified_chances[Enums.CharacterState.DECEASED] *= modifier.modifier_consequence_multiplier
	
	# Normalize probabilities
	var total = 0.0
	for chance in modified_chances.values():
		total += chance
	
	var probabilities = {}
	for state in modified_chances:
		probabilities[state] = modified_chances[state] / total
	
	return probabilities

"""
@brief Determines the consequence of a failed action
@param district_heat The current heat level of the district
@return Dictionary containing the result and roll value
"""
func determine_consequence(district_heat: int) -> Dictionary:
	var probabilities = get_consequence_probabilities(district_heat)
	
	# Define consequence order (most severe first)
	var consequence_order = [
		Enums.CharacterState.DECEASED,
		Enums.CharacterState.MIA,
		Enums.CharacterState.INJURED,
		Enums.CharacterState.ASSIGNED
	]
	
	# Roll and check against cumulative probability
	var roll = randf()
	var cumulative_probability = 0.0
	
	for consequence in consequence_order:
		cumulative_probability += probabilities[consequence]
		if roll < cumulative_probability:
			return {
				"result": consequence,
				"roll": roll
			}
	
	return {
		"result": Enums.CharacterState.ASSIGNED,
		"roll": roll
	}
