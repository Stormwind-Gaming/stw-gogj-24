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

	var base_sympathy_added: int = MathHelpers.generateBellCurveStat(min_value, max_value)
	print("Base value: ", base_sympathy_added)

	for modifier in modifiers:
		print("Modifier: ", modifier.modifier_name, " ", base_sympathy_added, " * ", modifier.modifier_sympathy_multiplier)
		base_sympathy_added *= modifier.modifier_sympathy_multiplier

	print("--- END SYMPATHY ADDED ---")

	return base_sympathy_added

func heat_added(min_value: int, max_value: int) -> int:
	print("--- HEAT ADDED ---")
	print("Base range: ", min_value, " ", max_value)

	var base_heat_added: int = MathHelpers.generateBellCurveStat(min_value, max_value)
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
@brief Gets the combined stats of all characters involved in the action
"""
func _get_stats() -> Dictionary:
	var _stats: Dictionary = {
		"subtlety": 0,
		"smarts": 0,
		"charm": 0
	}

	for character in characters:
		_stats["subtlety"] += character.char_subtlety
		_stats["smarts"] += character.char_smarts
		_stats["charm"] += character.char_charm

	return _stats

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
