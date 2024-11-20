extends Node
class_name BaseAction

#|==============================|
#|         Properties           |
#|==============================|
"""
@brief The Point of Interest where this action takes place
"""
var poi: PointOfInterest

"""
@brief Array of characters involved in this action
"""
var characters: Array[Character]

"""
@brief The type of action being performed
"""
var action_type: Enums.ActionType

"""
@brief Optional additional information for the action
Contains contextual data such as secondary characters or specific targets
"""
var additional_info: Dictionary = {}

"""
@brief The turn number when this action will end
"""
var turn_to_end: int = 0

"""
@brief The intelligence plan associated with this action
"""
var associated_plan: Plan = null

"""
@brief Whether this action is currently in progress
"""
var in_flight: bool = false

#|==============================|
#|        Initialization        |
#|==============================|
"""
@brief Initializes a new Action instance.

@param poi The Point of Interest where the action takes place
@param characters Array of characters involved in the action
@param action_type The type of action being performed
@param additional_info Optional dictionary containing extra information
"""
func _init(config: ActionFactory.ActionConfig):
	print("BaseAction init")

	self.poi = config.poi
	self.characters = config.characters
	self.action_type = config.action_type
	self.additional_info = config.additional_info

	# Set all characters to assigned
	for character in characters:
		character.char_state = Enums.CharacterState.ASSIGNED

	# Calculate the turn to end
	turn_to_end = GameController.turn_number + StatisticModification.mission_duration_modification(1, poi.parent_district.district_type)

	if additional_info.has("associated_plan"):
		self.associated_plan = config.additional_info["associated_plan"]

		turn_to_end = GameController.turn_number + StatisticModification.mission_duration_modification(self.associated_plan.plan_duration, poi.parent_district.district_type)
	

	EventBus.turn_processing_initiated.connect(_on_turn_processing_initiated)
	EventBus.end_turn_complete.connect(_on_end_turn_completed)

	EventBus.action_created.emit(self)

"""
@brief Called when the turn begins processing
"""
func _on_turn_processing_initiated(num: int) -> void:
	in_flight = true

	var danger_logs: Array[TurnLog] = []
	var action_logs: Array[TurnLog] = []

	if num >= turn_to_end:

		danger_logs = _process_danger()
		action_logs = _process_action()

		# Make sure the plan is removed at this point
		if associated_plan:
			associated_plan.call_deferred("free")

	else:
		action_logs.append(TurnLog.new("Action in progress by " + _get_character_names(), Enums.LogType.ACTION_INFO))
		
	for step in danger_logs + action_logs:
		GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), step)
		

"""
@brief Called when the turn ends
"""
func _on_end_turn_completed(num: int) -> void:
	if num >= turn_to_end:
		_release_characters()

		# Delete the action
		self.queue_free()

# Child classes must implement this method
func _process_action() -> Array[TurnLog]:
	push_error("_process_action() must be implemented by child classes")
	return []

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the object is being deleted.
Unregisters the action from the global registry.

@param what The notification type being received
"""
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		GlobalRegistry.actions.remove_item(self)
		EventBus.action_destroyed.emit(self)
		_release_characters()

#|==============================|
#|      Action Processing      |
#|==============================|

"""
@brief Processes the danger of an action
"""
func _process_danger() -> Array[TurnLog]:
	var logs: Array[TurnLog] = []

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	logs.append(TurnLog.new("Processing danger for action at [u]" + str(poi.poi_name) + "[/u] by " + _get_character_names(), Enums.LogType.ACTION_INFO))

	# Add detailed stats logging
	logs.append(TurnLog.new("Character stats - Subtlety: " + str(stats["subtlety"]) + ", Smarts: " + str(stats["smarts"]) + ", Charm: " + str(stats["charm"]), Enums.LogType.ACTION_INFO))

	var subtle_roll = MathHelpers.bounded_sigmoid_check(stats["subtlety"], true, Constants.SUBTLETY_CHECK_MIN_CHANCE, Constants.SUBTLETY_CHECK_MAX_CHANCE)

	# Add detailed roll logging
	logs.append(TurnLog.new("Subtlety Check Details:", Enums.LogType.ACTION_INFO))
	logs.append(TurnLog.new("- Base stat: " + str(subtle_roll.stat), Enums.LogType.ACTION_INFO))
	logs.append(TurnLog.new("- Raw chance (unbounded): " + str(subtle_roll.raw_chance) + "%", Enums.LogType.ACTION_INFO))
	logs.append(TurnLog.new("- Min chance: " + str(Constants.SUBTLETY_CHECK_MIN_CHANCE) + "%", Enums.LogType.ACTION_INFO))
	logs.append(TurnLog.new("- Max chance: " + str(Constants.SUBTLETY_CHECK_MAX_CHANCE) + "%", Enums.LogType.ACTION_INFO))
	logs.append(TurnLog.new("- Final success chance (bounded): " + str(subtle_roll.success_chance) + "%", Enums.LogType.ACTION_INFO))
	logs.append(TurnLog.new("- Roll result: " + str(subtle_roll.roll), Enums.LogType.ACTION_INFO))
	logs.append(TurnLog.new("- Final outcome: " + ("Success" if subtle_roll.success else "Failure"), Enums.LogType.ACTION_INFO))

	EventBus.stat_created.emit("subtlety", subtle_roll.success)

	var log_message: String = ""
	var heat_added: int = 0
		
	if (subtle_roll.success):
		heat_added = MathHelpers.generateBellCurveStat(Constants.ACTION_EFFECT_SUCCESS_SUBTLETY_MIN, Constants.ACTION_EFFECT_SUCCESS_SUBTLETY_MAX)
		logs.append(TurnLog.new("Success heat calculation:", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Min heat: " + str(Constants.ACTION_EFFECT_SUCCESS_SUBTLETY_MIN), Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Max heat: " + str(Constants.ACTION_EFFECT_SUCCESS_SUBTLETY_MAX), Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Generated heat: " + str(heat_added), Enums.LogType.ACTION_INFO))
		log_message = "Succeeded subtlety check... heat increased by " + str(heat_added)
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))

	else:
		heat_added = MathHelpers.generateBellCurveStat(Constants.ACTION_EFFECT_FAILED_SUBTLETY_MIN, Constants.ACTION_EFFECT_FAILED_SUBTLETY_MAX)
		logs.append(TurnLog.new("Failure heat calculation:", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Min heat: " + str(Constants.ACTION_EFFECT_FAILED_SUBTLETY_MIN), Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Max heat: " + str(Constants.ACTION_EFFECT_FAILED_SUBTLETY_MAX), Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Generated heat: " + str(heat_added), Enums.LogType.ACTION_INFO))

		EventBus.district_heat_changed.emit(poi.parent_district, heat_added)

		var district: District = poi.parent_district
		var base_district_heat = district.heat
		var district_heat: int = StatisticModification.heat_modification(district.heat, district.district_type)
		
		logs.append(TurnLog.new("District heat calculation:", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Base district heat: " + str(base_district_heat), Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- District type: " + str(district.district_type), Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Modified district heat: " + str(district_heat), Enums.LogType.ACTION_INFO))

		var consequence_result = _determine_action_failure_consequence(district_heat)
		var probabilities = _get_consequence_probabilities(district_heat)
		
		logs.append(TurnLog.new("Consequence calculation:", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("Base probabilities (before heat):", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- No consequence: " + str(probabilities[Enums.CharacterState.ASSIGNED] * 100) + "%", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Injured: " + str(probabilities[Enums.CharacterState.INJURED] * 100) + "%", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- MIA: " + str(probabilities[Enums.CharacterState.MIA] * 100) + "%", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Death: " + str(probabilities[Enums.CharacterState.DECEASED] * 100) + "%", Enums.LogType.ACTION_INFO))
		
		logs.append(TurnLog.new("Heat modification:", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- District heat: " + str(district_heat), Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Heat factor: " + str(district_heat / 100.0), Enums.LogType.ACTION_INFO))
		
		logs.append(TurnLog.new("Modified probabilities (after heat):", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- No consequence: " + str(probabilities[Enums.CharacterState.ASSIGNED] * 100) + "%", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Injured: " + str(probabilities[Enums.CharacterState.INJURED] * 100) + "%", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- MIA: " + str(probabilities[Enums.CharacterState.MIA] * 100) + "%", Enums.LogType.ACTION_INFO))
		logs.append(TurnLog.new("- Death: " + str(probabilities[Enums.CharacterState.DECEASED] * 100) + "%", Enums.LogType.ACTION_INFO))

		var consequence_log_type: Enums.EventOutcomeType
		match consequence_result.result:
			Enums.CharacterState.ASSIGNED:
				log_message = "No consequence"
			Enums.CharacterState.INJURED:
				log_message = "One character is injured"
				characters.shuffle()
				characters[0].char_state = Enums.CharacterState.INJURED
				consequence_log_type = Enums.EventOutcomeType.INJURED
			Enums.CharacterState.MIA:
				log_message = "One character is missing"
				characters.shuffle()
				characters[0].char_state = Enums.CharacterState.MIA
				consequence_log_type = Enums.EventOutcomeType.MIA

				# emit stats change
				EventBus.stat_created.emit("mia", true)
			Enums.CharacterState.DECEASED:
				log_message = "One character is deceased"
				characters.shuffle()
				characters[0].char_state = Enums.CharacterState.DECEASED
				consequence_log_type = Enums.EventOutcomeType.DECEASED

				# emit stats change
				EventBus.stat_created.emit("dead", true)
			_:
				log_message = "Unknown consequence"

		logs.append(TurnLog.new(log_message, Enums.LogType.CONSEQUENCE, consequence_log_type, poi, characters))

	return logs


func _determine_action_failure_consequence(district_heat: int) -> Dictionary:
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
	
	# Calculate sum for normalization
	var total = 0.0
	for chance in modified_chances.values():
		total += chance
	
	# Normalize probabilities
	var probabilities = {}
	for state in modified_chances:
		probabilities[state] = modified_chances[state] / total
	
	# Roll the dice
	var roll = randf()
	var cumulative_probability = 0.0
	
	for consequence in probabilities:
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

#|==============================|
#|      Helper Methods          |
#|==============================|

"""
@brief Gets the combined stats of all characters involved in the action
"""
func _get_stats() -> Dictionary:
	var stats: Dictionary = {
		"subtlety": 0,
		"smarts": 0,
		"charm": 0
	}

	for character in characters:
		stats["subtlety"] += StatisticModification.character_stat_modification(character.char_subtlety, Enums.StatCheckType.SUBTLETY)
		stats["smarts"] += StatisticModification.character_stat_modification(character.char_smarts, Enums.StatCheckType.SMARTS)
		stats["charm"] += StatisticModification.character_stat_modification(character.char_charm, Enums.StatCheckType.CHARM)

	return stats

"""
@brief Releases characters that are assigned to this action
"""
func _release_characters() -> void:
	for character in characters:
		# If the character is assigned to this action (e.g. not missing or deceased), set them to available
		if character.char_state == Enums.CharacterState.ASSIGNED:
			character.char_state = Enums.CharacterState.AVAILABLE
			EventBus.character_state_changed.emit(character)

"""
@brief Gets the names of the characters involved in the action
"""
func _get_character_names() -> String:
	var names: String = ""
	for character in characters:
		names += "[u]" + character.char_full_name + "[/u], "

	names = names.left(names.length() - 2)
	return names

func _get_consequence_probabilities(district_heat: int) -> Dictionary:
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
	
	# Calculate sum for normalization
	var total = 0.0
	for chance in modified_chances.values():
		total += chance
	
	# Normalize probabilities
	var probabilities = {}
	for state in modified_chances:
		probabilities[state] = modified_chances[state] / total
	
	return probabilities
