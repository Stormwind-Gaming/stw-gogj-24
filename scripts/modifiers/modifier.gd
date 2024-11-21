extends Node

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

func _init(config: Dictionary, mods: Dictionary) -> void:
	modifier_name = config.get("modifier_name", "Unnamed Modifier")
	district = config.get("district", null)
	scope = config.get("scope", Enums.ModifierScope.DISTRICT)
	active = config.get("active", true)

	turn_to_end = config.get("turn_to_end", -1)
	scope = config.get("scope", Enums.ModifierScope.DISTRICT)
	modifier_end_closure = config.get("modifier_end_closure", func(): return false)
	modifier_active_closure = config.get("modifier_active_closure", func(): return true)

	modifier_smarts_flat = mods.get("modifier_smarts_flat", 0)
	modifier_subtlety_flat = mods.get("modifier_subtlety_flat", 0)
	modifier_charm_flat = mods.get("modifier_charm_flat", 0)

	modifier_action_duration_flat = mods.get("modifier_action_duration_flat", 0)
	modifier_intel_spawn_flat = mods.get("modifier_intel_spawn_flat", 0)

	modifier_heat_multiplier = mods.get("modifier_heat_multiplier", 1.0)
	modifier_sympathy_multiplier = mods.get("modifier_sympathy_multiplier", 1.0)
	modifier_action_duration_multiplier = mods.get("modifier_action_duration_multiplier", 1.0)
	modifier_intel_spawn_multiplier = mods.get("modifier_intel_spawn_multiplier", 1.0)
	modifier_consequence_multiplier = mods.get("modifier_consequence_multiplier", 1.0)

	EventBus.modifier_created.emit(self)
	EventBus.end_turn_complete.connect(_on_end_turn_complete)

func _on_end_turn_complete(_num: int) -> void:
	# Check for end of modifier
	if modifier_end_closure.call() or (GameController.turn_number >= turn_to_end and turn_to_end != -1):
		EventBus.end_turn_complete.disconnect(_on_end_turn_complete)
		queue_free()

	# Run the check to see if the modifier should be active
	active = modifier_active_closure.call()