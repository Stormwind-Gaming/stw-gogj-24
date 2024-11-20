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
@brief Container for the list of known characters
"""
@export var known_character_list_container: GridContainer

"""
@brief Container for the list of unknown characters
"""
@export var unknown_character_list_container: GridContainer

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
	populate_character_lists()
	_recalculate_agent_count()

#|==============================|
#|      List Management        |
#|==============================|
"""
@brief Populates all character lists with the provided characters.
Sorts and distributes characters to appropriate lists based on their status.

@param characters Dictionary of all characters to be distributed
"""
func populate_character_lists():
	print('populating character lists')
	# Clear existing children in all containers
	for child in known_character_list_container.get_children():
		child.queue_free()
	for child in unknown_character_list_container.get_children():
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

	for character in GlobalRegistry.characters.get_list(GlobalRegistry.LIST_MIA):
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		mia_list_container.add_child(mini_agent_card_scene)

	for character in GlobalRegistry.characters.get_list(GlobalRegistry.LIST_DECEASED):
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		deceased_list_container.add_child(mini_agent_card_scene)

	for character in GlobalRegistry.characters.get_list(GlobalRegistry.LIST_NON_SYMPATHISER_KNOWN):
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.enable_popup_interaction()
		mini_agent_card_scene.set_character(character)
		known_character_list_container.add_child(mini_agent_card_scene)

	for character in GlobalRegistry.characters.get_list(GlobalRegistry.LIST_NON_SYMPATHISER_UNKNOWN):
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		unknown_character_list_container.add_child(mini_agent_card_scene)

	for character in GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED):
		var agent_card_scene = Globals.agent_card_scene.instantiate()
		agent_card_scene.on_character_list_page()
		agent_card_scene.set_character(character)
		agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		agent_list_container.add_child(agent_card_scene)

	for character in GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_NOT_RECRUITED):
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.on_character_list_page()
		mini_agent_card_scene.set_character(character)
		if not character.char_state == Enums.CharacterState.INJURED:
			mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		sympathiser_list_container.add_child(mini_agent_card_scene)


#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles character button press events.
Manages character recruitment and agent status changes.

@param character_node The character whose button was pressed
"""
func _on_character_button_pressed(character: Character) -> void:
	if character.char_recruitment_state == Enums.CharacterRecruitmentState.SYMPATHISER_RECRUITED:
		character.char_recruitment_state = Enums.CharacterRecruitmentState.SYMPATHISER_NOT_RECRUITED
	else:
		# Check if we're at the agent limit
		if GlobalRegistry.characters.list_size(GlobalRegistry.LIST_SYMPATHISER_RECRUITED) >= GameController.max_agents:
			return
		else:
			character.char_recruitment_state = Enums.CharacterRecruitmentState.SYMPATHISER_RECRUITED


	populate_character_lists()
	_recalculate_agent_count()

"""
@brief Handles the close button press event.
"""
func _on_close_button_pressed() -> void:
	EventBus.close_window.emit()

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Recalculates and updates the agent count display.
"""
func _recalculate_agent_count() -> void:

	var agent_count = GlobalRegistry.characters.list_size(GlobalRegistry.LIST_SYMPATHISER_RECRUITED)
	
	agents_label.text = "Agents (" + str(agent_count) + "/" + str(GameController.max_agents) + ")"
