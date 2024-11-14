extends Window

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Container for the list of deceased characters
"""
@export var deceased_list_container: GridContainer

"""
@brief Container for the list of MIA characters
"""
@export var mia_list_container: GridContainer

"""
@brief Container for the list of all characters
"""
@export var all_character_list_container: GridContainer

"""
@brief Container for the list of sympathiser characters
"""
@export var sympathiser_list_container: GridContainer

"""
@brief Container for the list of agent characters
"""
@export var agent_list_container: VBoxContainer

"""
@brief Label showing the current agent count
"""
@export var agents_label: Label

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Fetches characters and populates the lists.
"""
func _ready():
	var characters = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	populate_character_lists(characters)
	_recalculate_agent_count()

#|==============================|
#|      List Management        |
#|==============================|
"""
@brief Populates all character lists with the provided characters.
Sorts and distributes characters to appropriate lists based on their status.

@param characters Dictionary of all characters to be distributed
"""
func populate_character_lists(characters):
	# Clear existing children in all containers
	for child in all_character_list_container.get_children():
		child.queue_free()
	for child in sympathiser_list_container.get_children():
		child.queue_free()
	for child in agent_list_container.get_children():
		child.queue_free()
	for child in deceased_list_container.get_children():
		child.queue_free()
	for child in mia_list_container.get_children():
		child.queue_free()

	var all_characters = []
			
	# Distribute characters to appropriate lists based on status
	for name in characters.keys():
		var character = characters[name]

		match character.char_role:
			Enums.CharacterRole.DEFAULT:
				all_characters.append(character)
			Enums.CharacterRole.SYMPATHISER:
				var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
				mini_agent_card_scene.on_character_list_page()
				mini_agent_card_scene.set_character(character.id)
				mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
				sympathiser_list_container.add_child(mini_agent_card_scene)

		match character.char_status:
			Enums.CharacterStatus.MIA:
				var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
				mini_agent_card_scene.set_character(character.id)
				mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
				mia_list_container.add_child(mini_agent_card_scene)
			Enums.CharacterStatus.DECEASED:
				var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
				mini_agent_card_scene.set_character(character.id)
				mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
				deceased_list_container.add_child(mini_agent_card_scene)

		match character.char_knowledge:
			Enums.CharacterKnowledge.RECRUITED:
				var agent_card_scene = Globals.agent_card_scene.instantiate()
				agent_card_scene.on_character_list_page()
				agent_card_scene.set_character(character.id)
				agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
				agent_list_container.add_child(agent_card_scene)




		# 	agent_card_scene.set_character(character.id)
		# 	agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		# 	agent_list_container.add_child(agent_card_scene)



		# if character.char_status == Enums.CharacterStatus.DEFAULT:
		# elif character_node.recruited:
		# elif character_node.current_status == Enums.CharacterStatus.SYMPATHISER:
		# elif character_node.current_status == Enums.CharacterStatus.DECEASED:
		# elif character_node.current_status == Enums.CharacterStatus.MIA:

	#TODO: update this sort
	# Sort characters by known status
	# all_characters.sort_custom(func(a, b):
	# 	if a.known and not b.known:
	# 		return true
	# 	else:
	# 		return false
	# )

	# Add sorted characters to the all characters list
	for character in all_characters:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		if character.char_knowledge == Enums.CharacterKnowledge.NOT_RECRUITED:
			mini_agent_card_scene.enable_popup_interaction()
		mini_agent_card_scene.set_character(character.id)
		all_character_list_container.add_child(mini_agent_card_scene)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles character button press events.
Manages character recruitment and agent status changes.

@param character_node The character whose button was pressed
"""
func _on_character_button_pressed(character: Character) -> void:
	if character.char_knowledge == Enums.CharacterKnowledge.RECRUITED:
		character.unset_agent()
	else:
		# Check if we're at the agent limit
		var agents = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
		var agent_count = 0
		for name in agents.keys():
			var agent = agents[name]
			if agent.recruited:
				agent_count += 1
		if agent_count >= GameController.max_agents:
			return
		else:
			character.set_agent()

	var characters = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	populate_character_lists(characters)
	_recalculate_agent_count()

"""
@brief Handles the close button press event.
"""
func _on_close_button_pressed() -> void:
	GameController.set_menu_closed("CharacterList")
	queue_free()

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Recalculates and updates the agent count display.
"""
func _recalculate_agent_count() -> void:
	var agents = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	var agent_count = 0
	for id in agents.keys():
		var agent = agents[id]
		if agent.char_knowledge == Enums.CharacterKnowledge.RECRUITED:
			agent_count += 1
	agents_label.text = "Agents (" + str(agent_count) + "/" + str(GameController.max_agents) + ")"
