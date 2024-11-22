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
	# print('populating character lists')
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

	var characters_mia = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_MIA)
	for character in characters_mia:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		mia_list_container.add_child(mini_agent_card_scene)

	var characters_deceased = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_DECEASED)
	for character in characters_deceased:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		deceased_list_container.add_child(mini_agent_card_scene)

	var characters_known = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_NON_SYMPATHISER_KNOWN)
	for character in characters_known:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.enable_popup_interaction()
		mini_agent_card_scene.set_character(character)
		known_character_list_container.add_child(mini_agent_card_scene)

	var characters_unknown = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_NON_SYMPATHISER_UNKNOWN)
	for character in characters_unknown:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		unknown_character_list_container.add_child(mini_agent_card_scene)

	var characters_sympathiser_recruited = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED)
	for character in characters_sympathiser_recruited:
		var agent_card_scene = Globals.agent_card_scene.instantiate()
		agent_card_scene.on_character_list_page()
		agent_card_scene.set_character(character)
		agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		agent_list_container.add_child(agent_card_scene)
	
	var spare_agent_slots = GameController.max_agents - len(characters_sympathiser_recruited)
	for i in range(spare_agent_slots):
		var agent_card_scene = Globals.blank_agent_card_scene.instantiate()
		agent_list_container.add_child(agent_card_scene)

	var characters_sympathiser = GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_NOT_RECRUITED)
	for character in characters_sympathiser:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		if not character.char_state == Enums.CharacterState.INJURED and not (len(characters_sympathiser_recruited) >= GameController.max_agents):
			mini_agent_card_scene.on_character_list_page()
			mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
			
		sympathiser_list_container.add_child(mini_agent_card_scene)
	
	# for each list, if empty, add a label to indicate no characters
	if deceased_list_container.get_child_count() == 0:
		var margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_top", 5)
		margin_container.add_theme_constant_override("margin_left", 5)
		var label = Label.new()
		label.text = "No deceased characters"
		margin_container.add_child(label)
		deceased_list_container.add_child(margin_container)

	if mia_list_container.get_child_count() == 0:
		var margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_top", 5)
		margin_container.add_theme_constant_override("margin_left", 5)
		var label = Label.new()
		label.text = "No MIA characters"
		margin_container.add_child(label)
		mia_list_container.add_child(margin_container)
	
	if known_character_list_container.get_child_count() == 0:
		var margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_top", 5)
		margin_container.add_theme_constant_override("margin_left", 5)
		var label = Label.new()
		label.text = "No known characters"
		margin_container.add_child(label)
		known_character_list_container.add_child(margin_container)
	
	if unknown_character_list_container.get_child_count() == 0:
		var margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_top", 5)
		margin_container.add_theme_constant_override("margin_left", 5)
		var label = Label.new()
		label.text = "No unknown characters"
		margin_container.add_child(label)
		unknown_character_list_container.add_child(margin_container)
	
	if sympathiser_list_container.get_child_count() == 0:
		var margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_top", 5)
		margin_container.add_theme_constant_override("margin_left", 5)
		var label = Label.new()
		label.text = "No sympathiser characters"
		margin_container.add_child(label)
		sympathiser_list_container.add_child(margin_container)
	
	if agent_list_container.get_child_count() == 0:
		# special case
		pass
	


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
