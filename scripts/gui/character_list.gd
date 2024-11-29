extends Window

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief TabContainer for the character list
"""
@export var character_list_tab_container: TabContainer

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

"""
@brief OptionButton for sorting characters
"""
@export var sort_option_button: OptionButton


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

	var characters_mia = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_MIA)
	for character in characters_mia:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		mia_list_container.add_child(mini_agent_card_scene)

	var characters_deceased = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_DECEASED)
	for character in characters_deceased:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		mini_agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		deceased_list_container.add_child(mini_agent_card_scene)

	var characters_known = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_NON_SYMPATHISER_KNOWN)
	# sort characters based on sort_option_button
	match sort_option_button.selected:
		0:
			characters_known.sort_custom(func(x, y): x.char_sympathy > y.char_sympathy)
		1:
			characters_known.sort_custom(func(x, y): x.char_subtlety > y.char_subtlety)
		2:
			characters_known.sort_custom(func(x, y): x.char_charm > y.char_charm)
		3:
			characters_known.sort_custom(func(x, y): x.char_smarts > y.char_smarts)
		_:
			pass
	for character in characters_known:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.enable_popup_interaction()
		mini_agent_card_scene.set_character(character)
		known_character_list_container.add_child(mini_agent_card_scene)

	var characters_unknown = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_NON_SYMPATHISER_UNKNOWN)
	for character in characters_unknown:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		unknown_character_list_container.add_child(mini_agent_card_scene)

	var characters_sympathiser_recruited = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_SYMPATHISER_RECRUITED)
	for character in characters_sympathiser_recruited:
		var agent_card_scene = Globals.agent_card_scene.instantiate()
		agent_card_scene.on_character_list_page()
		agent_card_scene.set_character(character)
		agent_card_scene.connect("character_card_pressed", _on_character_button_pressed)
		agent_list_container.add_child(agent_card_scene)
	
	var spare_agent_slots = ReferenceGetter.game_controller().max_agents - len(characters_sympathiser_recruited)
	for i in range(spare_agent_slots):
		var agent_card_scene = Globals.blank_agent_card_scene.instantiate()
		agent_list_container.add_child(agent_card_scene)

	var characters_sympathiser = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_SYMPATHISER_NOT_RECRUITED)
	for character in characters_sympathiser:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.set_character(character)
		if not character.char_state == Enums.CharacterState.INJURED and not (len(characters_sympathiser_recruited) >= ReferenceGetter.game_controller().max_agents):
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
	
func jump_to_page(page: int) -> void:
	LogDuck.d("Jumping to page %s" % page)
	character_list_tab_container.current_tab = page


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
		if ReferenceGetter.global_registry().characters.list_size(ReferenceGetter.global_registry().LIST_SYMPATHISER_RECRUITED) >= ReferenceGetter.game_controller().max_agents:
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

"""
@brief Handles the sort option button item selected event.

@param index The index of the selected item
"""
func _on_option_button_item_selected(index: int) -> void:
	for child in known_character_list_container.get_children():
		child.queue_free()

	var characters_known = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_NON_SYMPATHISER_KNOWN)
	# sort characters based on sort_option_button
	match index:
		0:
			characters_known.sort_custom(func(x, y):
				if x.char_sympathy > y.char_sympathy:
					return true
				return false
			)
		1:
			characters_known.sort_custom(func(x, y):
				if x.char_subtlety > y.char_subtlety:
					return true
				return false
			)
		2:
			characters_known.sort_custom(func(x, y):
				if x.char_charm > y.char_charm:
					return true
				return false
			)
		3:
			characters_known.sort_custom(func(x, y):
				if x.char_smarts > y.char_smarts:
					return true
				return false
			)
		_:
			pass
	
	for character in characters_known:
		var mini_agent_card_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_card_scene.enable_popup_interaction()
		mini_agent_card_scene.set_character(character)
		known_character_list_container.add_child(mini_agent_card_scene)

func sort_ascending(a, b):
	if a[1] < b[1]:
		return true
	return false


#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Recalculates and updates the agent count display.
"""
func _recalculate_agent_count() -> void:

	var agent_count = ReferenceGetter.global_registry().characters.list_size(ReferenceGetter.global_registry().LIST_SYMPATHISER_RECRUITED)
	
	agents_label.text = "Agents (" + str(agent_count) + "/" + str(ReferenceGetter.game_controller().max_agents) + ")"
