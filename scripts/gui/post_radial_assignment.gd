extends Window

@export var agent_card_grid: GridContainer

var option: Enums.ActionType

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
		# if character_instance.recruited:
		agents.append(character)

	for agent in agents:
		var agent_instance = Globals.agent_card_scene.instantiate()
		agent_instance.set_character(agent)
		agent_card_grid.add_child(agent_instance)

func _on_close_requested():
	queue_free()
