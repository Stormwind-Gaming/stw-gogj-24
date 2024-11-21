extends Area2D
class_name PointOfInterest

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Popup window for POI information
"""
@export var poi_popup: Window

"""
@brief Whether this POI has static (predefined) properties
"""
@export var poi_static := true

"""
@brief Static configuration group
"""
@export_group("Static Variables")

"""
@brief Predefined POI type for static POIs
"""
@export var poi_static_type: Enums.POIType

"""
@brief Predefined name for static POIs
"""
@export var poi_static_name: String = ""

"""
@brief Predefined short description for static POIs
"""
@export var poi_static_short_description: String = ""

"""
@brief Predefined description for static POIs
"""
@export_multiline var poi_static_description: String = ""

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Whether the POI is currently interactable
"""
var enabled: bool = false

"""
@brief The district this POI belongs to
"""
var parent_district: District

"""
@brief Configuration for rumour generation chances
#TODO Dynamically change rumour_config for each POI
"""
var rumour_config: RumourConfig = RumourConfig.new(25, 25, 25)

"""
@brief Type of stat check for this POI
#TODO Dynamically change stat_check_type for each POI
"""
var stat_check_type: Enums.StatCheckType = Enums.StatCheckType.SMARTS

"""
@brief The type of this POI
"""
var poi_type: Enums.POIType

"""
@brief Name of this POI
"""
var poi_name: String = ""

"""
@brief Short description of this POI
"""
var poi_short_description: String = ""

"""
@brief Description of this POI
"""
var poi_description: String = ""

"""
@brief Character who owns this POI
"""
var poi_owner: Character

"""
@brief Bonus type provided by this POI
"""
var poi_bonus: Enums.POIBonusType = Enums.POIBonusType.NONE

"""
@brief Visual state colors
"""
var no_color = Color(0, 0, 0, 0)
var selectable_color = Color(0, 1, 0, 0.5)
var highlight_color = Color(1, 1, 1, 0.5)

"""
@brief Whether the mouse is currently hovering over this POI
"""
var hovered: bool = false

#|==============================|
#|          Signals            |
#|==============================|
"""
@brief Emitted when mouse enters POI area
"""
signal poi_hovered

"""
@brief Emitted when mouse exits POI area
"""
signal poi_unhovered

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Initializes POI properties and connects signals.
"""
func _ready() -> void:
	if not self.visible:
		# If the POI is not visible, then it is not part of the game
		return
	parent_district = get_parent().get_parent()
	EventBus.poi_created.emit(self)
	EventBus.character_state_changed.connect(_character_state_changed)
	EventBus.district_just_focused.connect(_on_district_just_focused)
	
	# Create the owner of the POI
	self.poi_owner = CharacterFactory.create_character()
	self.poi_bonus = _derive_poi_bonus()

	EventBus.action_created.connect(_on_action_created)
	EventBus.action_destroyed.connect(_on_action_destroyed)


"""
@brief Called every frame to update POI state.
Handles popup visibility based on hover state.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	if hovered and GameController.district_focused == parent_district:
			poi_popup.visible = true
			poi_popup.set_position(get_viewport().get_mouse_position() + Vector2(10, 10))
	else:
			poi_popup.visible = false

#|==============================|
#|      Setup Functions        |
#|==============================|
"""
@brief Sets up the visual elements of the POI
"""
func setup_poi_visuals():
	$Polygon2D.position = self.get_global_position()
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$Polygon2D.color = no_color
	
	# Calculate center of polygon
	var center = Vector2.ZERO
	var vertices = $CollisionPolygon2D.polygon
	for vertex in vertices:
		center += vertex
	center /= vertices.size()
	
	# Position ActionContainer at the center
	$ActionContainer.position = center

	$Polygon2D.visible = false

"""
@brief Sets the POI's details based on static or dynamic configuration.

@param parent_district_arg The district this POI belongs to
@param poi_type_arg The type of POI
@param poi_name_arg The name of the POI
@param poi_description_arg The description of the POI
"""
func set_poi_details(parent_district_arg: District, poi_type_arg: Enums.POIType, poi_name_arg: String, poi_description_arg: String, what_chance: int, where_chance: int, when_chance: int) -> void:
	parent_district = parent_district_arg
	if poi_static:
		poi_type = poi_static_type
		poi_name = poi_static_name
		poi_description = poi_static_description
	else:
		poi_type = poi_type_arg
		poi_name = poi_name_arg
		poi_description = poi_description_arg
		rumour_config = RumourConfig.new(what_chance, where_chance, when_chance)

	poi_description += '\n'
	poi_description += 'Owner: ' + poi_owner.get_full_name()
	poi_description += '\n'
	poi_description += 'Bonus: ' + Globals.get_poi_bonus_string(poi_bonus)
	
	poi_popup.set_details(poi_name, poi_description)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles mouse enter events.
Updates visual state and emits hover signal.
"""
func _on_mouse_entered():
	if not enabled:
		return

	if GameController.radial_menu_open != null:
		return

	if GameController.district_focused != parent_district:
		return
	
	hovered = true
	$Polygon2D.color = highlight_color
	emit_signal("poi_hovered", self)

"""
@brief Handles mouse exit events.
Updates visual state and emits unhover signal.
"""
func _on_mouse_exited():
	if not enabled:
		$Polygon2D.color = no_color
		await get_tree().create_timer(0.1).timeout
		if enabled:
			_on_mouse_exited()
		return
	else:
		$Polygon2D.color = selectable_color

	hovered = false
	emit_signal("poi_unhovered")

"""
@brief Handles click events on the POI.
Creates and displays the radial menu when appropriate.

@param viewport The viewport that received the event
@param event The input event
@param shape_idx The shape index that was clicked
"""
func _on_poi_clicked(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not enabled:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			poi_popup.visible = false
			
			if GameController.radial_menu_open != null:
				return
			
			if GameController.district_focused != parent_district:
				return

			var radial_menu_instance = Globals.radial_menu_scene.instantiate()
			radial_menu_instance.position = get_local_mouse_position()

			var actions: Array[Enums.ActionType] = []

			# If the endgame isnt active then add the normal actions
			if not GameController.endgame_triggered:
				actions.append(Enums.ActionType.ESPIONAGE)

				# Only non-sympathisers can use propaganda
				if poi_owner.char_recruitment_state < Enums.CharacterRecruitmentState.SYMPATHISER_NOT_RECRUITED:
					actions.append(Enums.ActionType.PROPAGANDA)

				# Only unknown non-sympathisers can use surveillance
				if poi_owner.char_recruitment_state == Enums.CharacterRecruitmentState.NON_SYMPATHISER_UNKNOWN:
					actions.append(Enums.ActionType.SURVEILLANCE)

			# If the POI has a plan then add the plan action
			if (_has_plan()):
				actions.append(Enums.ActionType.PLAN)

			radial_menu_instance.set_optional_actions(actions)
			EventBus.open_new_radial_menu.emit(radial_menu_instance)
			add_child(radial_menu_instance)

			GameController.open_radial_menu(radial_menu_instance, self)

"""
@brief Handles district focus changes.
Updates POI state based on whether its district is focused.

@param district The newly focused district
"""
func _on_district_just_focused(district: District) -> void:
	if district == parent_district:
		$Polygon2D.color = selectable_color
		await get_tree().create_timer(0.1).timeout
		enabled = true
		$Polygon2D.visible = true
	else:
		$Polygon2D.color = no_color
		enabled = false
		$Polygon2D.visible = false

"""
@brief Handles character state changes.
Updates POI popup details based on owner changes.

@param character The character whose state changed
"""
func _character_state_changed(character: Character) -> void:
	if character == poi_owner:
		poi_popup.set_details(poi_name, poi_description)
		if character.char_state == Enums.CharacterState.DECEASED:
			$Polygon2D.color = no_color
			enabled = false

"""
@brief Handles action creation events.
Updates POI state based on action creation.

@param action The action that was created
"""
func _on_action_created(action: BaseAction) -> void:
	if action.poi == self:
		var action_instance = Globals.action_scene.instantiate()
		action_instance.set_meta("action_reference", action)
		action_instance.get_node("Mask/TextureRect").texture = action.characters[0].char_picture
		$ActionContainer.add_child(action_instance)

"""
@brief Handles action destruction events.
Updates POI state based on action destruction.

@param action The action that was destroyed
"""
func _on_action_destroyed(action: BaseAction) -> void:
	if action.poi == self:
		for child in $ActionContainer.get_children():
			if child.get_meta("action_reference") == action:
				child.queue_free()
				break

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Determines the bonus type for this POI.
#TODO Implement proper bonus derivation based on POI type

@returns The derived POI bonus type
"""
func _derive_poi_bonus() -> Enums.POIBonusType:
	return Enums.POIBonusType.NONE

"""
@brief Checks if this POI has any associated plans.

@returns True if there are plans for this POI
"""
func _has_plan() -> bool:
	var plans = GlobalRegistry.intel.get_list(GlobalRegistry.LIST_PLANS)
	var has_plan = false
	for plan in plans:
		if plan.plan_subject_poi == self:
			var action = GlobalRegistry.actions.find_item(GlobalRegistry.LIST_ALL_ACTIONS, "associated_plan", plan)
			if not action or not action.in_flight:
				has_plan = true
				break
	return has_plan
