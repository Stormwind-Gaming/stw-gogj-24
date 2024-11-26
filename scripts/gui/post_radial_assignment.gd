extends Window

#|==============================|
#|      Exported Variables      |
#|==============================|
@onready var detection_label = find_child("DetectionLabel")
@onready var success_label = find_child("SuccessLabel")
@onready var modifiers_label = find_child("ModifiersLabel")
@onready var duration_label = find_child("DurationLabel")

"""
@brief Label displaying the task title
"""
@export var task_title: Label

"""
@brief Button to confirm the assignment
"""
@export var continue_button: Button

"""
@brief Grid container for agent cards
"""
@export var agent_card_grid: GridContainer

"""
@brief Label showing assigned agents count
"""
@export var asigned_label: Label

"""
@brief Label listing assigned agents
"""
@export var assigned_agents_label: Label

"""
@brief Label showing total charm stat
"""
@export var charm_label: Label

"""
@brief Label showing total subtlety stat
"""
@export var subtlety_label: Label

"""
@brief Label showing total smarts stat
"""
@export var smarts_label: Label

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief The type of action being assigned
"""
var option: Enums.ActionType

"""
@brief Maximum number of agents that can be assigned
"""
var max_agents: int = 1

"""
@brief Array of currently selected agents
"""
var selected_agents: Array[Character] = []

#|==============================|
#|          Signals            |
#|==============================|
"""
@brief Emitted when the assignment is confirmed
@param option The type of action being assigned
@param agents Array of assigned agents
@param additions Array of additional parameters
"""
signal post_radial_assignment_option(option: Enums.ActionType, agents: Array[Character], additions: Array)

#|==============================|
#|      Setters & Getters      |
#|==============================|
"""
@brief Sets the action type for this assignment.

@param option_attr The type of action to assign
"""
func set_option(option_attr: Enums.ActionType) -> void:
	self.option = option_attr

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Sets up the assignment window and populates agent cards.
"""
func _ready():
	# calculate type
	var type = ''
	if option == Enums.ActionType.PLAN:
		type = 'Plan'
	else:
		type = 'Action'
	# set title
	task_title.text = "%s - %s" % [Globals.get_action_type_string(option), type]

	# populate the agents list
	var agents: Array[Character] = []
	var recruited_agents = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED)
	for character in recruited_agents:
		if character.char_state == Enums.CharacterState.AVAILABLE:
		# if the character is available, add them to the list
			agents.push_front(character)
		else:
		# if the character is assigned, put them to the bottom of the list
			agents.push_back(character)

	for agent in agents:
		var agent_instance = Globals.agent_card_scene.instantiate()
		agent_instance.set_character(agent)
		agent_instance.connect('agent_card_selected', _on_agent_card_selected)
		agent_card_grid.add_child(agent_instance)
		agent_instance.check_assignment_selection(GameController.poi_for_radial, option)
	
	# set max agents based on the action type
	match option:
		Enums.ActionType.PLAN:
			max_agents = Constants.ACTION_PLAN_MAX_AGENTS
		Enums.ActionType.SURVEILLANCE:
			max_agents = Constants.ACTION_SURVEILLANCE_MAX_AGENTS
		Enums.ActionType.PROPAGANDA:
			max_agents = Constants.ACTION_PROPAGANDA_MAX_AGENTS
		Enums.ActionType.ESPIONAGE:
			max_agents = Constants.ACTION_ESPIONAGE_MAX_AGENTS
		_:
			max_agents = 1

	asigned_label.text = 'Assigned Agents (0/%s):' % max_agents

	continue_button.disabled = true

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles agent card selection events.
Updates the UI and manages agent selection state.

@param agent The agent being selected/deselected
@param selected Whether the agent is being selected or deselected
"""
func _on_agent_card_selected(agent: Character, selected: bool):
	# check if the agent is already selected
	if !selected:
		selected_agents.erase(agent)
		GameController.remove_all_actions_for_character(agent)

		# enable all cards
		for child in agent_card_grid.get_children():
			child.enable_card()
		
		# if no cards are selected, disable the button
		if selected_agents.size() == 0:
			continue_button.disabled = true
	else:
		# enable the button
		continue_button.disabled = false
		
		# add the agent to the selected agents
		selected_agents.append(agent)
		if selected_agents.size() >= max_agents:
			# disable all other agents
			for child in agent_card_grid.get_children():
				if child.character not in selected_agents:
					child.disable_card()
	
	_calculate_stats()

"""
@brief Handles the continue button press.
Emits the assignment completion signal.
"""
func _on_button_pressed() -> void:
	emit_signal('post_radial_assignment_option', option, selected_agents, [])
	EventBus.close_window.emit()

"""
@brief Handles the close button press.
Emits a cancellation signal.
"""
func _on_close_button_pressed() -> void:
	emit_signal('post_radial_assignment_option', Enums.ActionType.NONE, selected_agents, [])
	EventBus.close_window.emit()

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Calculates and updates the total stats for selected agents.
Updates the UI labels with new totals.
"""
func _calculate_stats():
	var charm = 0
	var subtlety = 0
	var smarts = 0
	
	asigned_label.text = 'Assigned Agents (%s/%s):' % [selected_agents.size(), max_agents]
	
	assigned_agents_label.text = ''
	for agent in selected_agents:
		assigned_agents_label.text += agent.get_full_name() + '\n'

	if selected_agents.size() > 0:

		var statistic_check: StatisticCheck = StatisticCheck.new(selected_agents, GameController.poi_for_radial.parent_district, GameController.poi_for_radial)
		detection_label.text = "Chance of Detection: %s" % str(floor((1 - statistic_check.get_subtlety_chance()) * 100)) + "%"

		#TODO: Get the duration from the action
		duration_label.text = "Duration: %s Turns" % str(statistic_check.action_duration(1))

		var stats = statistic_check.stats
		charm = stats.charm
		subtlety = stats.subtlety
		smarts = stats.smarts

		if selected_agents.size() > 1:
			var modifiers = statistic_check.get_team_modifiers()
			modifiers_label.text = "Team Modifiers:"
			modifiers_label.text += "\nComplementarity: %s" % modifiers.complementarity.effect
			for stat in modifiers.complementarity.stat_changes:
				modifiers_label.text += "\n%s: %s" % [stat, modifiers.complementarity.stat_changes[stat]]
			modifiers_label.text += "\nOverspecialization: %s" % modifiers.overspecialization.effect
			for stat in modifiers.overspecialization.stat_changes:
				modifiers_label.text += "\n%s: %s" % [stat, modifiers.overspecialization.stat_changes[stat]]
		else:
			modifiers_label.text = ""

		match option:
			Enums.ActionType.PROPAGANDA:
				success_label.text = "Chance of Success: %s" % str(floor((statistic_check.get_charm_chance()) * 100)) + "%"
			Enums.ActionType.SURVEILLANCE:
				success_label.text = "Chance of Success: %s" % str(floor((statistic_check.get_smarts_chance()) * 100)) + "%"
			Enums.ActionType.ESPIONAGE:
				# Get the stat for this poi espoionage
				match GameController.poi_for_radial.stat_check_type:
					Enums.StatCheckType.CHARM:
						success_label.text = "Chance of Success: %s" % str(floor((statistic_check.get_charm_chance()) * 100)) + "%"
					Enums.StatCheckType.SMARTS:
						success_label.text = "Chance of Success: %s" % str(floor((statistic_check.get_smarts_chance()) * 100)) + "%"
			_:
				# TODO: Calculate which stat is going to be checked for the plan action
			# Enums.ActionType.PLAN:
				success_label.text = ""

	else:
		detection_label.text = "Chance of Detection: 0%"
		success_label.text = "Chance of Success: 0%"
		modifiers_label.text = ""
	
	charm_label.text = "Charm: %s" % str(charm)
	
	subtlety_label.text = "Subtlety: %s" % str(subtlety)
	smarts_label.text = "Smarts: %s" % str(smarts)
