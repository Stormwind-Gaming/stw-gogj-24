extends Window

@export var task_title: Label
@export var continue_button: Button
@export var agent_card_grid: GridContainer
@export var asigned_label: Label
@export var assigned_agents_label: Label
@export var charm_label: Label
@export var subtlety_label: Label
@export var smarts_label: Label

var option: Enums.ActionType
var max_agents: int = 1

var selected_agents: Array[Character] = []

signal post_radial_assignment_option(option: Enums.ActionType, agents: Array[Character], additions: Array)

func set_option(option_attr: Enums.ActionType) -> void:
	self.option = option_attr

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
	var agents = []
	for character in GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER):
		var character_instance = GlobalRegistry.get_object(Enums.Registry_Category.CHARACTER, character)
		if character_instance.recruited:
			if character_instance.current_status == Enums.CharacterStatus.AVAILABLE:
				# if the character is available, add them to the list
				agents.push_front(character)
			if character_instance.current_status == Enums.CharacterStatus.ASSIGNED:
				# if the character is assigned, put them to the bottom of the list
				agents.push_back(character)

	for agent in agents:
		var agent_instance = Globals.agent_card_scene.instantiate()
		agent_instance.set_character(agent)
		agent_instance.connect('agent_card_selected', _on_agent_card_selected)
		agent_card_grid.add_child(agent_instance)
		agent_instance.check_assignment_selection(GameController.poi_for_radial, option)
	
	# set max agents to 1 or 2
	max_agents = 1 # randi() % 2 + 1
	asigned_label.text = 'Assigned Agents (0/%s):' % max_agents

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


func _calculate_stats():
	var charm = 0
	var subtlety = 0
	var smarts = 0
	for agent in selected_agents:
		charm += agent.charm
		subtlety += agent.subtlety
		smarts += agent.smarts
	
	charm_label.text = "Charm: %s" % str(charm)
	
	subtlety_label.text = "Subtlety: %s" % str(subtlety)
	smarts_label.text = "Smarts: %s" % str(smarts)

	asigned_label.text = 'Assigned Agents (%s/%s):' % [selected_agents.size(), max_agents]
	
	assigned_agents_label.text = ''
	for agent in selected_agents:
		assigned_agents_label.text += agent.get_full_name() + '\n'


func _on_button_pressed() -> void:
	emit_signal('post_radial_assignment_option', option, selected_agents, [])
	queue_free()


func _on_close_button_pressed() -> void:
	emit_signal('post_radial_assignment_option', Enums.ActionType.NONE, selected_agents, [])
	queue_free()
