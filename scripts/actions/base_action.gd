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
	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)
	turn_to_end = statistic_check.action_duration(GameController.turn_number + 1)

	if additional_info.has("associated_plan"):
		self.associated_plan = config.additional_info["associated_plan"]

		# turn_to_end = GameController.turn_number + StatisticModification.mission_duration_modification(self.associated_plan.plan_duration, poi.parent_district.district_type)
		# TODO: should this be the plan duration?
		turn_to_end = GameController.turn_number

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
		if associated_plan and not associated_plan.is_endgame_plan:
			associated_plan.call_deferred("free")

	else:
		action_logs.append(TurnLog.new("Action in progress by " + _get_character_names(), Enums.LogType.ACTION_INFO))
		
	for step in danger_logs + action_logs:
		GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), step)
		

"""
@brief Called when the turn ends
"""
func _on_end_turn_completed(num: int) -> void:
	print("Turn to end action: ", turn_to_end)

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

	var statistic_check: StatisticCheck = StatisticCheck.new(characters, poi.parent_district, poi)

	var subtle_roll = statistic_check.subtlety_check()

	var log_message: String = ""
	var heat_added: int = 0
		
	if (subtle_roll):
		heat_added = statistic_check.heat_added(Constants.ACTION_EFFECT_SUCCESS_SUBTLETY_MIN, Constants.ACTION_EFFECT_SUCCESS_SUBTLETY_MAX)

		log_message = "Succeeded subtlety check... heat increased by " + str(heat_added)
		logs.append(TurnLog.new(log_message, Enums.LogType.ACTION_INFO))
		poi.parent_district.heat += heat_added

	else:
		heat_added = statistic_check.heat_added(Constants.ACTION_EFFECT_FAILED_SUBTLETY_MIN, Constants.ACTION_EFFECT_FAILED_SUBTLETY_MAX)
		poi.parent_district.heat += heat_added

		var district: District = poi.parent_district
		var base_district_heat = district.heat
		# var district_heat: int = StatisticModification.heat_modification(district.heat, district.district_type)
		var district_heat: int = district.heat

		var consequence_result = _determine_action_failure_consequence(district_heat)
		var probabilities = _get_consequence_probabilities(district_heat)

		var consequence_log_type: Enums.EventOutcomeType
		match consequence_result.result:
			Enums.CharacterState.ASSIGNED:
				log_message = "No consequence"
			Enums.CharacterState.INJURED:
				log_message = "One character is injured"
				characters.shuffle()
				characters[0].char_state = Enums.CharacterState.INJURED
				consequence_log_type = Enums.EventOutcomeType.INJURED

				# emit stats change
				EventBus.stat_created.emit("injured", true)
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

		logs.append(TurnLog.new(log_message, Enums.LogType.CONSEQUENCE, poi, characters))
		EventBus.create_new_event_panel.emit(consequence_log_type, characters, poi)

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
		# stats["subtlety"] += StatisticModification.character_stat_modification(character.char_subtlety, Enums.StatCheckType.SUBTLETY)
		# stats["smarts"] += StatisticModification.character_stat_modification(character.char_smarts, Enums.StatCheckType.SMARTS)
		# stats["charm"] += StatisticModification.character_stat_modification(character.char_charm, Enums.StatCheckType.CHARM)
		stats["subtlety"] += character.char_subtlety
		stats["smarts"] += character.char_smarts
		stats["charm"] += character.char_charm

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
