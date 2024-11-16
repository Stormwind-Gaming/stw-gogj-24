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
@brief The turn number when this action will expire if not completed
"""
var turn_to_expire: int = 0

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

	EventBus.turn_processing_initiated.connect(_on_turn_processing_initiated)
	EventBus.end_turn_complete.connect(_on_end_turn_completed)

	EventBus.action_created.emit(self)

"""
@brief Called when the turn begins processing
"""
func _on_turn_processing_initiated(num:int) -> void:
	in_flight = true
	var danger_logs = _process_danger()
	var action_logs = _process_action()

	for step in danger_logs + action_logs:
		GlobalRegistry.turn_logs.add_item(str(GameController.turn_number), step)


"""
@brief Called when the turn ends
"""
func _on_end_turn_completed(num:int) -> void:
	if num >= turn_to_end:
		_release_characters()

		# Delete the action
		self.queue_free()

# Child classes must implement this method
func _process_action() -> Array[String]:
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
		_release_characters()

#|==============================|
#|      Action Processing      |
#|==============================|

"""
@brief Processes the danger of an action
"""
func _process_danger() -> Array[String]:

	var logs: Array[String] = []

	# Get cumulative stats for all characters involved
	var stats: Dictionary = _get_stats()

	logs.append("Processing danger for action at [u]" + str(poi.poi_name))

	var subtle_roll = MathHelpers.bounded_sigmoid_check(stats["subtlety"], true)

	var log_message: String = ""
		
	if(subtle_roll.success):
		log_message = "Succeeded subtlety check..."
		logs.append(log_message)

	else:
		log_message = "Failed subtlety check... heat increased by " + str(Constants.ACTION_EFFECT_FAILED_SUBTLETY)
		EventBus.district_heat_changed.emit(poi.parent_district, Constants.ACTION_EFFECT_FAILED_SUBTLETY)
		logs.append(log_message)

		# Determine the consequence of the action failure
		var district_heat: int = poi.parent_district.heat

		log_message = "Determining consequence of action failure... district heat is " + str(district_heat)
		logs.append(log_message)

		match _determine_action_failure_consequence(district_heat):
			Enums.CharacterState.ASSIGNED:
				log_message = "No consequence"
			Enums.CharacterState.MIA:
				log_message = "One character is missing"
				characters.shuffle()
				characters[0].char_state = Enums.CharacterState.MIA
			Enums.CharacterState.DECEASED:
				log_message = "One character is deceased"
				characters.shuffle()
				characters[0].char_state = Enums.CharacterState.DECEASED
			_:
				log_message = "Unknown consequence"

		logs.append(log_message)

	return logs


func _determine_action_failure_consequence(district_heat: int) -> int:
	# Total probability should equal 1.0 (100%)
	var base_chances = {
			Enums.CharacterState.ASSIGNED: 0.85,    # 85% chance nothing happens
			Enums.CharacterState.MIA: 0.1,          # 10% chance for MIA
			Enums.CharacterState.DECEASED: 0.05     # 5% chance for death
	}
	
	# As heat increases, redistribute probabilities (scaled down by half)
	var heat_factor = district_heat / 100.0
	var modified_chances = {
			Enums.CharacterState.ASSIGNED: base_chances[Enums.CharacterState.ASSIGNED] * (1.0 - heat_factor * 0.5),
			Enums.CharacterState.MIA: base_chances[Enums.CharacterState.MIA] + (heat_factor * 0.1),
			Enums.CharacterState.DECEASED: base_chances[Enums.CharacterState.DECEASED] + (heat_factor * 0.1)
	}
	
	# Roll the dice
	var roll = randf()
	var cumulative_probability = 0.0
	
	for consequence in modified_chances:
			cumulative_probability += modified_chances[consequence]
			if roll < cumulative_probability:
					return consequence
	
	return Enums.CharacterState.ASSIGNED

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

# """
# @brief Processes an espionage action

# @param action The action to process
# """
# func _espionage_action(action:Action) -> void:
# 	var log_message = "Processing ESPIONAGE action at [u]" + str(action.poi.poi_name) + "[/u] by "

# 	var success = false

# 	for character in action.characters:
# 		log_message += "[u]" + character.first_name + " " + character.last_name + "[/u], "

# 	current_turn_log.append(log_message)

# 	var combined_subtlety = 0
# 	var combined_smarts = 0
# 	var combined_charm = 0

# 	for character in action.characters:
# 		combined_subtlety += character.subtlety
# 		combined_smarts += character.smarts
# 		combined_charm += character.charm
	
# 	var subtle_roll = MathHelpers.bounded_sigmoid_check(combined_subtlety, true)
	
# 	if(subtle_roll.success):
# 		log_message = "Succeeded subtlety check..."
# 		# log_message += str(subtle_roll)
# 		current_turn_log.append(log_message)

# 	else:
# 		log_message = "Failed subtlety check... heat increased"
# 		# log_message += str(subtle_roll)
# 		action.poi.parent_district.heat += 5
# 		current_turn_log.append(log_message)
		
# 	match action.poi.stat_check_type:
# 		Enums.StatCheckType.SMARTS:
			
# 			var smarts_roll = MathHelpers.bounded_sigmoid_check(combined_smarts, true)
			
# 			if(smarts_roll.success):
# 				log_message = "Succeeded smarts check..."
# 			# log_message += str(smarts_roll)
# 				current_turn_log.append(log_message)
# 				success = true
# 			else: 
# 				log_message = "Failed smarts check..."
# 			# log_message += str(smarts_roll)
# 				current_turn_log.append(log_message)

# 		Enums.StatCheckType.CHARM:
# 			if(MathHelpers.bounded_sigmoid_check(combined_charm)):
# 				log_message = "Succeeded charm check..."
# 				current_turn_log.append(log_message)
# 				success = true
# 			else: 
# 				log_message = "Failed charm check..."
# 				current_turn_log.append(log_message)

# 	if success:
# 		log_message = "[color=green]The mission was a success![/color]"
# 		current_turn_log.append(log_message)
# 		IntelFactory.create_rumour(action.poi.rumour_config)
# 	else:
# 		log_message = "[color=red]The mission was a failure! :([/color]"
# 		current_turn_log.append(log_message)

# 	current_turn_log.append("\n")

# func _surveillance_action(action:Action) -> void:

# 	var log_message = "Processing SURVEILLANCE action at [u]" + str(action.poi.poi_name) + "[/u] by "

# 	var success = false

# 	for character in action.characters:
# 		log_message += "[u]" + character.first_name + " " + character.last_name + "[/u], "

# 	current_turn_log.append(log_message)

# 	var combined_subtlety = 0
# 	var combined_smarts = 0
# 	var combined_charm = 0

# 	for character in action.characters:
# 		combined_subtlety += character.subtlety
# 		combined_smarts += character.smarts
# 		combined_charm += character.charm
	
# 	var subtle_roll = MathHelpers.bounded_sigmoid_check(combined_subtlety, true)
	
# 	if(subtle_roll.success):
# 		log_message = "Succeeded subtlety check..."
# 		# log_message += str(subtle_roll)
# 		current_turn_log.append(log_message)

# 	else:
# 		log_message = "Failed subtlety check... heat increased"
# 		# log_message += str(subtle_roll)
# 		action.poi.parent_district.heat += 5
# 		current_turn_log.append(log_message)

# 	var smarts_roll = MathHelpers.bounded_sigmoid_check(combined_smarts, true)
# 	
# 	if(smarts_roll.success):
# 		log_message = "Succeeded smarts check..."
# 	# log_message += str(smarts_roll)
# 		current_turn_log.append(log_message)
# 		success = true
# 	else: 
# 		log_message = "Failed smarts check..."
# 	# log_message += str(smarts_roll)
# 		current_turn_log.append(log_message)

# 	if success:
# 		log_message = "[color=green]The mission was a success![/color]"
# 		current_turn_log.append(log_message)
# 		action.poi.poi_owner.known = true
# 		log_message = "[color=green]" + action.poi.poi_owner.get_full_name() + " is now known to us[/color]"
# 		current_turn_log.append(log_message)
# 	else:
# 		log_message = "[color=red]The mission was a failure! :([/color]"
# 		current_turn_log.append(log_message)

# 	current_turn_log.append("\n")

# func _propaganda_action(action:Action) -> void:
# 	var log_message = "Processing PROPAGANDA action at [u]" + str(action.poi.poi_name) + "[/u] by "

# 	var success = false

# 	for character in action.characters:
# 		log_message += "[u]" + character.first_name + " " + character.last_name + "[/u], "

# 	current_turn_log.append(log_message)

# 	var combined_subtlety = 0
# 	var combined_smarts = 0
# 	var combined_charm = 0

# 	for character in action.characters:
# 		combined_subtlety += character.subtlety
# 		combined_smarts += character.smarts
# 		combined_charm += character.charm
	
# 	var subtle_roll = MathHelpers.bounded_sigmoid_check(combined_subtlety, true)
	
# 	if(subtle_roll.success):
# 		log_message = "Succeeded subtlety check..."
# 		# log_message += str(subtle_roll)
# 		current_turn_log.append(log_message)

# 	else:
# 		log_message = "Failed subtlety check... heat increased"
# 		# log_message += str(subtle_roll)
# 		action.poi.parent_district.heat += 5
# 		current_turn_log.append(log_message)

# 	if(MathHelpers.bounded_sigmoid_check(combined_charm)):
# 		log_message = "Succeeded charm check..."
# 		current_turn_log.append(log_message)
# 		success = true
# 	else: 
# 		log_message = "Failed charm check..."
# 		current_turn_log.append(log_message)

# 	if success:
# 		log_message = "[color=green]The mission was a success![/color]"
# 		current_turn_log.append(log_message)
# 		action.poi.poi_owner.set_sympathy(action.poi.poi_owner.sympathy + 5)
# 		log_message = "[color=green]" + action.poi.poi_owner.get_full_name() + " is now more sympathetic to our cause![/color]"
# 		current_turn_log.append(log_message)
# 	else:
# 		log_message = "[color=red]The mission was a failure! :([/color]"
# 		current_turn_log.append(log_message)

# 	current_turn_log.append("\n")

# func _plan_action(action:Action) -> void:

# 	var log_message = "Processing PLAN action at [u]" + str(action.poi.poi_name) + "[/u] by "

# 	var success = false

# 	for character in action.characters:
# 		log_message += "[u]" + character.first_name + " " + character.last_name + "[/u], "

# 	current_turn_log.append(log_message)

# 	var combined_subtlety = 0
# 	var combined_smarts = 0
# 	var combined_charm = 0

# 	for character in action.characters:
# 		combined_subtlety += character.subtlety
# 		combined_smarts += character.smarts
# 		combined_charm += character.charm

# 	log_message = "oh god... how is this bit supposed to work?! "

# 	current_turn_log.append(log_message)