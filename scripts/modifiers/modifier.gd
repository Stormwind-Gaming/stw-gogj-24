extends NodeWithCleanup

class_name Modifier

var modifier_name: String = ""
var active: bool = true
var turn_to_end: int = -1
var scope: Enums.ModifierScope = Enums.ModifierScope.DISTRICT
var district: District = null
var modifier_end_closure: Callable = func(): return false
var modifier_active_closure: Callable = func(): return true

# Flat stat modifiers
var modifier_smarts_flat: int = 0
var modifier_subtlety_flat: int = 0
var modifier_charm_flat: int = 0

# Flat modifiers
var modifier_action_duration_flat: int = 0
var modifier_intel_spawn_flat: int = 0

# Multiplier modifiers
var modifier_heat_multiplier: float = 1.0
var modifier_sympathy_multiplier: float = 1.0
var modifier_action_duration_multiplier: float = 1.0
var modifier_intel_spawn_multiplier: float = 1.0
var modifier_consequence_multiplier: float = 1.0
var modifier_subtlety_multiplier: float = 1.0

func _init(config: Dictionary, mods: Dictionary) -> void:
	LogDuck.d("Creating new modifier", {
		"name": config.get("modifier_name", "Unnamed Modifier"),
		"scope": config.get("scope", Enums.ModifierScope.DISTRICT),
		"district": config.get("district", null).district_name if config.get("district", null) else "None",
		"turn_to_end": config.get("turn_to_end", -1)
	})

	modifier_name = config.get("modifier_name", "Unnamed Modifier")
	district = config.get("district", null)
	scope = config.get("scope", Enums.ModifierScope.DISTRICT)
	active = config.get("active", true)

	turn_to_end = config.get("turn_to_end", -1)
	scope = config.get("scope", Enums.ModifierScope.DISTRICT)
	modifier_end_closure = config.get("modifier_end_closure", func(): return false)
	modifier_active_closure = config.get("modifier_active_closure", func(): return true)

	# Log flat modifiers
	LogDuck.d("Setting flat stat modifiers", {
		"name": modifier_name,
		"smarts": mods.get("modifier_smarts_flat", 0),
		"subtlety": mods.get("modifier_subtlety_flat", 0),
		"charm": mods.get("modifier_charm_flat", 0)
	})

	modifier_smarts_flat = mods.get("modifier_smarts_flat", 0)
	modifier_subtlety_flat = mods.get("modifier_subtlety_flat", 0)
	modifier_charm_flat = mods.get("modifier_charm_flat", 0)

	# Log other flat modifiers
	LogDuck.d("Setting other flat modifiers", {
		"name": modifier_name,
		"action_duration": mods.get("modifier_action_duration_flat", 0),
		"intel_spawn": mods.get("modifier_intel_spawn_flat", 0)
	})

	modifier_action_duration_flat = mods.get("modifier_action_duration_flat", 0)
	modifier_intel_spawn_flat = mods.get("modifier_intel_spawn_flat", 0)

	# Log multiplier modifiers
	LogDuck.d("Setting multiplier modifiers", {
		"name": modifier_name,
		"heat": mods.get("modifier_heat_multiplier", 1.0),
		"sympathy": mods.get("modifier_sympathy_multiplier", 1.0),
		"action_duration": mods.get("modifier_action_duration_multiplier", 1.0),
		"intel_spawn": mods.get("modifier_intel_spawn_multiplier", 1.0),
		"consequence": mods.get("modifier_consequence_multiplier", 1.0)
	})

	modifier_heat_multiplier = mods.get("modifier_heat_multiplier", 1.0)
	modifier_sympathy_multiplier = mods.get("modifier_sympathy_multiplier", 1.0)
	modifier_action_duration_multiplier = mods.get("modifier_action_duration_multiplier", 1.0)
	modifier_intel_spawn_multiplier = mods.get("modifier_intel_spawn_multiplier", 1.0)
	modifier_consequence_multiplier = mods.get("modifier_consequence_multiplier", 1.0)
	modifier_subtlety_multiplier = mods.get("modifier_subtlety_multiplier", 1.0)

	EventBus.modifier_created.emit(self)
	EventBus.end_turn_complete.connect(_on_end_turn_complete)

func _on_end_turn_complete(_num: int) -> void:	
	LogDuck.d("Checking modifier end conditions", {
		"name": modifier_name,
		"current_turn": ReferenceGetter.game_controller().turn_number,
		"end_turn": turn_to_end,
		"active": active
	})

	# Check for end of modifier
	if modifier_end_closure.call() or (ReferenceGetter.game_controller().turn_number >= turn_to_end and turn_to_end != -1):
		LogDuck.d("Modifier ending", {
			"name": modifier_name,
			"reason": "end_closure" if modifier_end_closure.call() else "turn_limit_reached"
		})
		EventBus.end_turn_complete.disconnect(_on_end_turn_complete)
		queue_free()

	# Run the check to see if the modifier should be active
	var was_active = active
	active = modifier_active_closure.call()
	
	if was_active != active:
		LogDuck.d("Modifier active state changed", {
			"name": modifier_name,
			"previous": was_active,
			"current": active
		})

"""
@brief Get the text for the modification effect
"""
func get_modification_effect_text() -> String:
	var text = ""

	if modifier_smarts_flat != 0:
		text += "Smarts: +%s" % modifier_smarts_flat
	if modifier_subtlety_flat != 0:
		text += "Subtlety: +%s" % modifier_subtlety_flat
	if modifier_charm_flat != 0:
		text += "Charm: +%s" % modifier_charm_flat

	if modifier_action_duration_flat != 0:
		text += "Plan/Action Duration: +%s" % modifier_action_duration_flat
	if modifier_intel_spawn_flat != 0:
		text += "Intel Spawn: +%s" % modifier_intel_spawn_flat

	if modifier_heat_multiplier > 1.0:
		text += "Heat Multiplier: +%s" % _convert_decimal_to_percentage(modifier_heat_multiplier)
	if modifier_sympathy_multiplier > 1.0:
		text += "Sympathy Multiplier: +%s" % _convert_decimal_to_percentage(modifier_sympathy_multiplier)
	if modifier_action_duration_multiplier > 1.0:
		text += "Plan/Action Duration Multiplier: +%s" % _convert_decimal_to_percentage(modifier_action_duration_multiplier)
	if modifier_intel_spawn_multiplier > 1.0:
		text += "Intel Spawn Multiplier: +%s" % _convert_decimal_to_percentage(modifier_intel_spawn_multiplier)
	if modifier_consequence_multiplier > 1.0:
		text += "Chance of Injury: +%s" % _convert_decimal_to_percentage(modifier_consequence_multiplier)
	if modifier_subtlety_multiplier > 1.0:
		text += "Subtlety Multiplier: +%s" % _convert_decimal_to_percentage(modifier_subtlety_multiplier)
	
	if modifier_heat_multiplier < 1.0:
		text += "Heat Multiplier: %s" % _convert_decimal_to_percentage(modifier_heat_multiplier)
	if modifier_sympathy_multiplier < 1.0:
		text += "Sympathy Multiplier: %s" % _convert_decimal_to_percentage(modifier_sympathy_multiplier)
	if modifier_action_duration_multiplier < 1.0:
		text += "Plan/Action Duration Multiplier: %s" % _convert_decimal_to_percentage(modifier_action_duration_multiplier)
	if modifier_intel_spawn_multiplier < 1.0:
		text += "Intel Spawn Multiplier: %s" % _convert_decimal_to_percentage(modifier_intel_spawn_multiplier)
	if modifier_consequence_multiplier < 1.0:
		text += "Chance of Injury: %s" % _convert_decimal_to_percentage(modifier_consequence_multiplier)
	if modifier_subtlety_multiplier < 1.0:
		text += "Subtlety Multiplier: %s" % _convert_decimal_to_percentage(modifier_subtlety_multiplier)

	return text

"""
@brief Convert a decimal value to a percentage string
"""
func _convert_decimal_to_percentage(value: float) -> String:
	return "%s%%" % str((value - 1) * 100)
