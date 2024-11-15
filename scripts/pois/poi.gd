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
var rumour_config : RumourConfig = RumourConfig.new(25,25,25)

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
	parent_district = get_parent().get_parent()
	GlobalRegistry.add_poi(self)
	GameController.connect("district_just_focused", _on_district_just_focused)
	
	# Create the owner of the POI
	self.poi_owner = CharacterFactory.create_character()
	self.poi_bonus = _derive_poi_bonus()

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

"""
@brief Sets the POI's details based on static or dynamic configuration.

@param parent_district_arg The district this POI belongs to
@param poi_type_arg The type of POI
@param poi_name_arg The name of the POI
@param poi_description_arg The description of the POI
"""
func set_poi_details(parent_district_arg: District, poi_type_arg: Enums.POIType, poi_name_arg: String, poi_description_arg: String) -> void:
	parent_district = parent_district_arg
	if poi_static:
		poi_type = poi_static_type
		poi_name = poi_static_name
		poi_description = poi_static_description
	else:
		poi_type = poi_type_arg
		poi_name = poi_name_arg
		poi_description = poi_description_arg
	
	var desc = ''
	desc += 'Owner: ' + poi_owner.get_full_name()
	desc += '\n'
	desc += 'Bonus: ' + Globals.get_poi_bonus_string(poi_bonus)
	
	poi_popup.set_details(poi_name, desc)

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
			if GameController.radial_menu_open != null:
				return
			
			if GameController.district_focused != parent_district:
				return

			var radial_menu_instance = Globals.radial_menu_scene.instantiate()
			radial_menu_instance.position = get_local_mouse_position()

			var actions = [
				Enums.ActionType.ESPIONAGE,
				Enums.ActionType.PROPAGANDA,
			] as Array[Enums.ActionType]

			if poi_owner.known == false:
				actions.append(Enums.ActionType.SURVEILLANCE)

			if(_has_plan()):
				actions.append(Enums.ActionType.PLAN)

			radial_menu_instance.set_optional_actions(actions)
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
	else:
		$Polygon2D.color = no_color
		enabled = false

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
	var poi_plans = GlobalRegistry.get_all_objects(Enums.Registry_Category.INTEL).values().filter(
			func(intel): return intel.level == Enums.IntelLevel.PLAN && intel.related_poi == self
	)

	return poi_plans.size() > 0
