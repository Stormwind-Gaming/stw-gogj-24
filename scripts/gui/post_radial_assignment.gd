extends Window

@export var agent_card_grid: GridContainer
@export var asigned_label: Label
@export var assigned_agents_label: Label
@export var charm_label: Label
@export var subtlety_label: Label
@export var smarts_label: Label

var option: Enums.ActionType
var max_agents: int = 2

var selected_agents: Array[Character] = []

signal post_radial_assignment_option(option: Enums.ActionType, agents: Array[Character], additions: Array)

func set_option(option_attr: Enums.ActionType) -> void:
	self.option = option_attr

func _ready():
	# set title
	title = '%s Task' % Globals.get_action_type_string(option)

	# Connect the close_requested signal
	close_requested.connect(_on_close_requested)
	
	# populate the agents list
	var agents = []
	for character in GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER):
		var character_instance = GlobalRegistry.get_object(Enums.Registry_Category.CHARACTER, character)
		if character_instance.recruited:
			agents.append(character)

	for agent in agents:
		var agent_instance = Globals.agent_card_scene.instantiate()
		agent_instance.set_character(agent)
		agent_instance.connect('agent_card_selected', _on_agent_card_selected)
		agent_card_grid.add_child(agent_instance)
	
	asigned_label.text = 'Assigned Agents (0/%s):' % max_agents

func _on_close_requested():
	queue_free()

func _on_agent_card_selected(agent: Character, selected: bool):
	# check if the agent is already selected
	if !selected:
		selected_agents.erase(agent)
		# enable all cards
		for child in agent_card_grid.get_children():
			child.enable_card()
	else:
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
