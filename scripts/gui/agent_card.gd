extends PanelContainer

#|==============================|
#|      Exported Variables       |
#|==============================|
@export var character_texture: TextureRect
@export var status_overlay: TextureRect

@export var gender_label: Label
@export var dob_label: Label
@export var nationality_label: Label
@export var profession_label: Label
@export var national_id_label: Label
@export var sympathy_progress: ProgressBar

@export var charm_label: Label
@export var subtlety_label: Label
@export var smarts_label: Label

@export var assignment_button: TextureButton
@export var set_unset_agent_button: TextureButton
@export var popup_button: TextureButton

var character: set = set_character

#|==============================|
#|           Signals            |
#|==============================|
signal agent_card_selected(character: Character, toggled_on: bool)
signal character_card_pressed(character: Character)

#|==============================|
#|        Lifecycle Methods     |
#|==============================|
"""
@brief Called when the node enters the scene tree for the first time.
Sets the initial status overlay based on the character's current status.
"""
func _ready():
	_set_state_overlay(character.char_state)
	_bind_character_signals()
	
	if not character.char_associated_poi:
		$JumpToButton.visible = false

#|==============================|
#|    Getters and Setters       |
#|==============================|
"""
@brief Sets the character for the agent card.

@param character_id The unique identifier of the character to set.
"""
func set_character(my_character: Character):
	character = my_character

	_assign_character_ui(character)

	var stats = character.get_stats()

	charm_label.text = stats.charm
	subtlety_label.text = stats.subtlety
	smarts_label.text = stats.smarts

	if character.char_state == Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN:
		sympathy_progress.visible = true

#|==============================|
#|       Event Listeners        |
#|==============================|
"""
@brief Emits the `agent_card_selected` signal when the assignment button is toggled.

@param toggled_on A boolean indicating whether the button is toggled on.
"""
func _on_assignment_button_toggled(toggled_on: bool) -> void:
	emit_signal('agent_card_selected', character, toggled_on)

"""
@brief Emits the `character_card_pressed` signal when the set/unset agent button is pressed.
"""
func _on_set_unset_agent_button_pressed() -> void:
	emit_signal('character_card_pressed', character)

"""
@brief Handles the popup button press by creating and displaying a new window with the full agent card.
"""
func _on_popup_button_pressed() -> void:
	# Create a new window with the full agent card
	var window = Window.new()
	# Set window to mouse location
	window.size = Vector2(300, 200)
	window.set_position(get_viewport().get_mouse_position() + Vector2(200, 0))
	window.exclusive = true
	window.unresizable = true
	window.borderless = true
	window.always_on_top = true
	window.transparent = true
	window.connect("mouse_exited",
		func():
			window.queue_free()
	)
	# Popup a full agent_card
	var agent_card_scene = Globals.agent_card_scene.instantiate()
	agent_card_scene.set_character(character)
	agent_card_scene.disable_card()
	window.add_child(agent_card_scene)
	window.show()
	self.add_child(window)

"""
@brief Handles changes to the character's status.

@param status The new status of the character.
"""
func _on_character_state_changed(character: Character) -> void:
	if character == self.character:
		_set_state_overlay(character.char_state)

"""
@brief Handles changes to the character's knowledge.

@param knowledge The new knowledge level of the character.
"""
func _on_character_recruitment_state_changed(character: Character) -> void:
	if character == self.character:
		pass
	pass

"""
@brief Handles the jump to button
"""
func _on_jump_to_button_pressed() -> void:
	EventBus.close_all_windows.emit()
	character.char_associated_poi.parent_district.district_clicked.emit(character.char_associated_poi.parent_district)

#|==============================|
#|        Helper Functions      |
#|==============================|
"""
@brief Binds character-related signals to their respective handlers.

@param character The Character instance whose signals are to be bound.
"""
func _bind_character_signals() -> void:
	# Connect to character signals
	EventBus.character_state_changed.connect(_on_character_state_changed)
	EventBus.character_recruitment_state_changed.connect(_on_character_recruitment_state_changed)

"""
@brief Assigns the character's data to the corresponding UI elements.

@param character The Character instance whose data is to be displayed.
"""
func _assign_character_ui(character: Character) -> void:
	# Assign strings to the UI
	$MarginContainer/VBoxContainer/Label.text = character.char_full_name
	
	character_texture.texture = character.char_picture

	var gender = ''
	match character.char_gender:
		Enums.CharacterGender.MALE:
			gender = 'Male'
			pass
		Enums.CharacterGender.FEMALE:
			gender = 'Female'
			pass
		_:
			pass
	gender_label.text = gender
	dob_label.text = character.char_dob
	nationality_label.text = Globals.get_nationality_string(character.char_nationality)
	profession_label.text = character.char_associated_poi.poi_profession
	national_id_label.text = str(character.char_national_id_number)
	sympathy_progress.value = character.char_sympathy

"""
@brief Updates the state overlay based on the character's state.

@param state The current state of the character.
"""
func _set_state_overlay(status: Enums.CharacterState) -> void:
	self.modulate = Color(1, 1, 1)

	if status == Enums.CharacterState.AVAILABLE:
		status_overlay.visible = false
		return
	if status == Enums.CharacterState.DECEASED or status == Enums.CharacterState.INJURED or status == Enums.CharacterState.MIA:
		self.modulate = Color(0.5, 0.5, 0.5)

	if status == Enums.CharacterState.INJURED:
		var label = Label.new()
		label.text = '1' # Turns is currently always 1
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", Color(1, 1, 1))
		label.add_theme_font_size_override("font_size", 24)
		self.add_child(label)
		pass 
	
	var status_texture = load('res://assets/character_status/' + Globals.get_character_state_string(status).to_lower() + '.png')
	status_overlay.texture = status_texture
	status_overlay.visible = true
	pass

"""
@brief Checks if the character is already assigned to a specific Point of Interest (POI) and action type.

@param poi The PointOfInterest to check assignment against.
@param option The ActionType to check assignment against.
"""
func check_assignment_selection(poi: PointOfInterest, option: Enums.ActionType) -> void:
	# Check this character's status
	if character.char_state == Enums.CharacterState.ASSIGNED:
		# If the character is assigned, check if they are assigned to this POI and action
		var actions = GlobalRegistry.actions.get_all_items()
		for action in actions:
			if action.characters.has(character) and action.poi == poi and action.action_type == option:
				self.modulate = Color(1, 1, 1)
				print('Character is already assigned to this action')
				status_overlay.visible = false
				assignment_button.button_pressed = true
			else:
				self.modulate = Color(0.5, 0.5, 0.5)

"""
@brief Disables the normal click functionality and enables the character list page functionality.
"""
func on_character_list_page() -> void:
	# Disable the normal click functionality of the card and enable the character list page functionality
	assignment_button.visible = false
	set_unset_agent_button.visible = true
	popup_button.visible = false

"""
@brief Enables the normal click functionality and disables the character list page functionality.
"""
func enable_popup_interaction() -> void:
	# Enable the normal click functionality of the card and disable the character list page functionality
	assignment_button.visible = false
	set_unset_agent_button.visible = false
	popup_button.visible = true

#|==============================|
#|        Utility Functions     |
#|==============================|
"""
@brief Disables the assignment button on the card.
"""
func disable_card() -> void:
	assignment_button.disabled = true

"""
@brief Enables the assignment button on the card.
"""
func enable_card() -> void:
	assignment_button.disabled = false
