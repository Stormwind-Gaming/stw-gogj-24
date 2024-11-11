extends PanelContainer

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
@export var character_page_button: TextureButton

var character : Character

signal agent_card_selected(character: Character)
signal character_card_pressed(character: Character)

func _ready():
	$MarginContainer/VBoxContainer/Label.text = character.first_name + " " + character.last_name
	
	var picture_texture = load(character.picture)
	character_texture.texture = picture_texture

	var gender = ''
	match character.gender:
		Enums.CharacterGender.MALE:
			gender = 'Male'
			pass
		Enums.CharacterGender.FEMALE:
			gender = 'Female'
			pass
		_:
			pass
	gender_label.text = gender
	dob_label.text = character.dob
	nationality_label.text = Globals.get_nationality_string(character.nationality)
	profession_label.text = Globals.get_profession_string(character.profession)
	national_id_label.text = str(character.national_id_number)
	sympathy_progress.value = character.sympathy

	_set_status_overlay(character.current_status)

func set_character(character_id: String):
	character = GlobalRegistry.get_object(Enums.Registry_Category.CHARACTER, character_id)
	charm_label.text = str(character.charm)
	subtlety_label.text = str(character.subtlety)
	smarts_label.text = str(character.smarts)

func disable_card() -> void:
	assignment_button.disabled = true

func enable_card() -> void:
	assignment_button.disabled = false

func _on_assignment_button_toggled(toggled_on: bool) -> void:
	emit_signal('agent_card_selected', character, toggled_on)

func _set_status_overlay(status: Enums.CharacterStatus) -> void:
	self.modulate = Color(1, 1, 1)
	if status == Enums.CharacterStatus.NONE or status == Enums.CharacterStatus.AVAILABLE:
		status_overlay.visible = false
		return
	var status_texture = load('res://assets/character_status/' + Globals.get_character_status_string(status).to_lower() + '.png')
	status_overlay.texture = status_texture
	status_overlay.visible = true
	pass

func check_assignment_selection(poi: PointOfInterest, option: Enums.ActionType) -> void:
	# check this characters status
	if character.current_status == Enums.CharacterStatus.ASSIGNED:
		# if the character is assigned, we need to check if they are assigned to this poi and action
		var actions = GameController.actions
		for action in actions:
			if action.characters.has(character) and action.poi == poi and action.action_type == option:
				print('Character is already assigned to this action')
				status_overlay.visible = false
				assignment_button.button_pressed = true
			else:
				self.modulate = Color(0.5, 0.5, 0.5)

func on_character_list_page() -> void:
	# this function disables the normal click functionality of the card and enables the character list page functionality
	assignment_button.visible = false
	character_page_button.visible = true
	pass

func _on_character_page_button_pressed() -> void:
	emit_signal('character_card_pressed', character)
