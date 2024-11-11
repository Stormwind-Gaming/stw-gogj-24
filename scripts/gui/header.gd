extends Control

@export var date: Label
@export var heat_bar: ProgressBar
@export var resistance_bar: ProgressBar

@export var agents_wrapper: VBoxContainer

func _ready():
	GameController.connect("end_turn_complete", _update_gui)
	GameController.connect("new_district_registered", _on_new_district_registered)
	GameController.connect("agent_changed", _on_agents_changed)
	GameController.connect("new_assignment", _on_new_assignment)
	resistance_bar.value = GameController.get_resistance_level()
	heat_bar.value = GameController.get_heat_level()
	date.text = GameController.calendar.get_date_string()

func _on_new_district_registered(district: District) -> void:
	_update_gui(0)

func _update_gui(number: int) -> void:
	date.text = GameController.calendar.get_date_string()
	resistance_bar.value = GameController.get_resistance_level()
	heat_bar.value = GameController.get_heat_level()
	_on_agents_changed()

func _on_new_assignment(option: Enums.ActionType, poi: PointOfInterest, agents: Array[Character]) -> void:
	_on_agents_changed(agents[0])

func _on_agents_changed(new_agent: Character = null) -> void:
	# update the sidebar list of agents
	# get all agents
	var agents = []
	for character_id in GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER):
		var character = GlobalRegistry.get_object(Enums.Registry_Category.CHARACTER, character_id)
		if character.recruited:
			agents.append(character)
	
	# clear the agents wrapper
	for child in agents_wrapper.get_children():
		child.queue_free()
	
	# add the agents to the wrapper
	for agent in agents:
		var agent_instance = Globals.mini_agent_card_scene.instantiate()
		agent_instance.set_character(agent.id)
		agents_wrapper.add_child(agent_instance)
	pass
