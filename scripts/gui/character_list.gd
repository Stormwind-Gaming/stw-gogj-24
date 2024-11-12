extends Window

@export var deceased_list_container: GridContainer
@export var mia_list_container: GridContainer
@export var all_character_list_container: GridContainer
@export var sympathiser_list_container: GridContainer
@export var agent_list_container: VBoxContainer
@export var agents_label: Label

func _ready():
	# Fetch characters from the GlobalRegistry and populate the list
	var characters = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	populate_character_lists(characters)
	_recalculate_agent_count()

func populate_character_lists(characters):
	# Clear existing children in the container by freeing them
	for child in all_character_list_container.get_children():
		child.queue_free()
	for child in sympathiser_list_container.get_children():
		child.queue_free()
	for child in agent_list_container.get_children():
		child.queue_free()
			
	for name in characters.keys():
		var character_node = characters[name]
		if character_node.current_status == Enums.CharacterStatus.NONE:
			var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
			mini_agent_card_scene.set_character(character_node.id)
			all_character_list_container.add_child(mini_agent_card_scene)
		elif character_node.recruited:
			var agent_card_scene = Globals.agent_card_scene.instantiate()
			agent_card_scene.on_character_list_page()
			agent_card_scene.set_character(character_node.id)
			agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
			agent_list_container.add_child(agent_card_scene)
		elif character_node.current_status == Enums.CharacterStatus.SYMPATHISER:
			var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
			mini_agent_card_scene.on_character_list_page()
			mini_agent_card_scene.set_character(character_node.id)
			mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
			sympathiser_list_container.add_child(mini_agent_card_scene)
		elif character_node.current_status == Enums.CharacterStatus.DECEASED:
			var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
			mini_agent_card_scene.set_character(character_node.id)
			mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
			deceased_list_container.add_child(mini_agent_card_scene)
		elif character_node.current_status == Enums.CharacterStatus.MIA:
			var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
			mini_agent_card_scene.set_character(character_node.id)
			mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
			mia_list_container.add_child(mini_agent_card_scene)


func _on_character_button_pressed(character_node: Character) -> void:
	# if the character is an agent, remove them from the agent list
	if character_node.recruited:
		character_node.unset_agent()
	else:
		# the character is a sympathiser, check if we're at the agent limit
		var agents = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
		var agent_count = 0
		for name in agents.keys():
			var agent = agents[name]
			if agent.recruited:
				agent_count += 1
		if agent_count >= GameController.max_agents:
			# we're at the agent limit
			return
		else:
			# we're not at the agent limit, promote the character to an agent
			character_node.set_agent()

	var characters = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	populate_character_lists(characters)
	_recalculate_agent_count()


func _on_close_button_pressed() -> void:
	GameController.set_menu_closed("CharacterList")
	queue_free()

func _recalculate_agent_count() -> void:
	var agents = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	var agent_count = 0
	for name in agents.keys():
		var agent = agents[name]
		if agent.recruited:
			agent_count += 1
	agents_label.text = "Agents (" + str(agent_count) + "/" + str(GameController.max_agents) + ")"
