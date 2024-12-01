extends Area2DWithCleanup
class_name PointOfInterest

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Popup window for POI information
"""
@export var poi_popup: Window

"""
@brief Icon for this POI
"""
@export var poi_icon: TextureRect

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
@brief Predefined profession for static POIs
"""
@export var poi_static_profession_arg: String = ""

"""
@brief Predefined short description for static POIs
"""
@export var poi_static_short_description: String = ""

"""
@brief Predefined description for static POIs
"""
@export_multiline var poi_static_description: String = ""

"""
@brief Predefined Misson intel chance
"""
@export var mission_static_chance: int = 1

"""
@brief Predefined Location intel chance
"""
@export var location_static_chance: int = 1

"""
@brief Predefined Timing intel chance
"""
@export var timing_static_chance: int = 1

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
"""
var rumour_config: RumourConfig = RumourConfig.new(25, 25, 25)

"""
@brief Type of stat check for this POI
"""
@export var stat_check_type: Enums.StatCheckType = Enums.StatCheckType.SMARTS

"""
@brief The type of this POI
"""
var poi_type: Enums.POIType

"""
@brief ID of this POI
"""
var poi_id: String = ""

"""
@brief Name of this POI
"""
var poi_name: String = ""

"""
@brief Profession of this POI
"""
var poi_profession: String = ""

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
@brief The most likely intel type for this POI
"""
var most_likely_intel_type: String

"""
@brief Visual state colors
"""
var no_color = Color(0, 0, 0, 0)
var highlight_color = Color(1, 1, 1, 0.5)

# black color
var black_color = Color(0, 0, 0, 0.5)
# soft blue color
var unknown_color = Color(0, 0, 1, 0.2)
# soft yellow color
var known_color = Color(1, 1, 0, 0.4)
# green color
var sympathiser_color = Color(0.133333, 0.545098, 0.133333, 0.5)

"""
@brief Whether the mouse is currently hovering over this POI
"""
var hovered: bool = false

"""
@brief Controls whether GUI debug logs are enabled
"""
var gui_debug: bool = false

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
		LogDuck.d("Skipping POI initialization - not visible")
		return
	parent_district = get_parent().get_parent()
	LogDuck.d("Initializing POI", {
		"district": parent_district.district_name,
		"static": poi_static
	})
	
	EventBus.poi_created.emit(self)
	EventBus.character_state_changed.connect(_character_state_changed)
	EventBus.district_just_focused.connect(_on_district_just_focused)
	EventBus.focus_on_poi.connect(_on_poi_focused)
	EventBus.close_radial_menu.connect(_reset_poi_state)

	EventBus.open_new_radial_menu.connect(_on_open_new_radial_menu)
	
	# Create the owner of the POI
	self.poi_owner = CharacterFactory.create_character()
	self.poi_owner.char_associated_poi = self
	self.poi_bonus = _derive_poi_bonus()
	
	LogDuck.d("POI owner created", {
		"owner": poi_owner.get_full_name(),
		"bonus_type": poi_bonus
	})

	EventBus.action_created.connect(_on_action_created)
	EventBus.action_destroyed.connect(_on_action_destroyed)

"""
@brief Called every frame to update POI state.
Handles popup visibility based on hover state.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	if hovered and ReferenceGetter.game_controller().district_focused == parent_district and not WindowHandler.any_windows_open():
		if not poi_popup.visible:
			poi_popup.visible = true
			poi_popup.check_details()
		
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
	LogDuck.d("Setting up POI visuals")
	poi_icon.material = ShaderMaterial.new()
	poi_icon.material.shader = Globals.black_to_white_shader

	$Polygon2D.position = self.get_global_position()
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$Polygon2D.color = no_color
	
	# Calculate center of polygon
	var center = Vector2.ZERO
	var vertices = $CollisionPolygon2D.polygon
	for vertex in vertices:
		center += vertex
	center /= vertices.size()
	
	LogDuck.d("POI visual setup complete", {
		"center": center,
		"vertices": vertices.size()
	})
	
	$ActionContainer.position = center
	$Polygon2D.visible = false
	$IconButton.position = center - $IconButton.size / 2
	$IconButton.visible = false

"""
@brief Sets the POI's details based on static or dynamic configuration.

@param parent_district_arg The district this POI belongs to
@param poi_type_arg The type of POI
@param poi_name_arg The name of the POI
@param poi_description_arg The description of the POI
"""
func set_poi_details(parent_district_arg: District, poi_type_arg: Enums.POIType, poi_name_arg: String, poi_profession_arg: String, poi_short_description_arg: String, poi_description_arg: String, what_chance_arg: int, where_chance_arg: int, when_chance_arg: int) -> void:
	LogDuck.d("Setting POI details", {
		"district": parent_district_arg.district_name,
		"type": poi_type_arg,
		"name": poi_name_arg
	})

	var what_tmp
	var where_tmp
	var when_tmp
	parent_district = parent_district_arg
	if poi_static:
		poi_type = poi_static_type
		
		poi_name = poi_static_name
		poi_profession = poi_static_profession_arg
		poi_description = poi_static_description
		
		poi_short_description = poi_static_short_description
		what_tmp = mission_static_chance
		where_tmp = location_static_chance
		when_tmp = timing_static_chance
	else:
		poi_type = poi_type_arg
		poi_name = poi_name_arg
		poi_profession = poi_profession_arg
		poi_description = poi_description_arg
		poi_short_description = poi_short_description_arg
		what_tmp = what_chance_arg
		where_tmp = where_chance_arg
		when_tmp = when_chance_arg

	
	rumour_config = RumourConfig.new(what_tmp, where_tmp, when_tmp)

	# Set the most likely intel type for this POI
	if what_tmp == where_tmp and what_tmp == when_tmp:
		most_likely_intel_type = "Even"
	elif what_tmp > where_tmp and what_tmp > when_tmp:
		most_likely_intel_type = "Mission"
	elif where_tmp > what_tmp and where_tmp > when_tmp:
		most_likely_intel_type = "Location"
	else:
		most_likely_intel_type = "Timing"

	poi_popup.set_details(self)
	
	# Set the icon
	poi_icon.texture = Globals.poi_icons[poi_type]

	LogDuck.d("POI details configured", {
		"name": poi_name,
		"type": poi_type,
		"most_likely_intel": most_likely_intel_type,
		"rumour_config": {
			"mission": rumour_config.mission_chance,
			"location": rumour_config.location_chance,
			"time": rumour_config.time_chance
		}
	})

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles mouse enter events.
Updates visual state and emits hover signal.
"""
func _on_mouse_entered():
	if not enabled or WindowHandler.any_windows_open():
		if gui_debug:
			LogDuck.d("POI hover ignored - disabled or window open")
		return

	if WindowHandler.any_windows_open():
		if gui_debug:
			LogDuck.d("POI hover ignored - radial menu open")
		return

	if ReferenceGetter.game_controller().district_focused != parent_district:
		if gui_debug:
			LogDuck.d("POI hover ignored - district not focused")
		return
	
	if gui_debug:
		LogDuck.d("POI hovered", {
			"name": poi_name,
			"district": parent_district.district_name
		})
	
	hovered = true
	$Polygon2D.color = highlight_color
	$IconButton.material.set_shader_parameter("enabled", true)
	poi_icon.material.set_shader_parameter("transition", 1.0)
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
		$Polygon2D.color = get_poi_color()

	# reset the hover effect
	$IconButton.material.set_shader_parameter("enabled", false)
	# set the icon colour to black
	poi_icon.material.set_shader_parameter("transition", 0.0)

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
			_poi_clicked()

func _reset_poi_state():
	_on_district_just_focused(ReferenceGetter.game_controller().district_focused)
	$IconButton.mouse_filter = Control.MOUSE_FILTER_STOP
			
"""
@brief Handles button click events.
Opens the POI radial menu when the button is clicked.
"""
func _on_icon_button_clicked() -> void:
	if not enabled:
		return
	_poi_clicked()

"""
@brief Handles POI click events.
Opens the POI radial menu when the POI is clicked.
"""
func _poi_clicked() -> void:
	if gui_debug:
		LogDuck.d("POI clicked", {
			"name": poi_name,
			"district": parent_district.district_name
		})
	
	poi_popup.visible = false

	if WindowHandler.any_windows_open():
		if gui_debug:
			LogDuck.d("POI click ignored - radial menu already open")
		return
	
	if ReferenceGetter.game_controller().district_focused != parent_district:
		if gui_debug:
			LogDuck.d("POI click ignored - district not focused")
		return
	
	var actions: Array[Enums.ActionType] = []
	if not ReferenceGetter.game_controller().endgame_triggered:
		# check if any actions are in flight for this POI
		var created_actions = ReferenceGetter.global_registry().actions.get_list(ReferenceGetter.global_registry().LIST_ALL_ACTIONS).filter(func(action): return (action.poi == self) and action.in_flight)
		
		# if any actions in flight are ESPIONAGE dont add the ESPIONAGE action
		if created_actions.size() == 0 or not created_actions.find(func(action): return action.action_type == Enums.ActionType.ESPIONAGE):
			actions.append(Enums.ActionType.ESPIONAGE)
		
		if not poi_owner.char_state in [Enums.CharacterState.DECEASED, Enums.CharacterState.MIA]:
			if poi_owner.char_recruitment_state < Enums.CharacterRecruitmentState.SYMPATHISER_NOT_RECRUITED:
				# if any actions in flight are PROPAGANDA dont add the PROPAGANDA action
				if created_actions.size() == 0 or not created_actions.find(func(action): return action.action_type == Enums.ActionType.PROPAGANDA):
					actions.append(Enums.ActionType.PROPAGANDA)
			if poi_owner.char_recruitment_state == Enums.CharacterRecruitmentState.NON_SYMPATHISER_UNKNOWN:
				# if any actions in flight are SURVEILLANCE dont add the SURVEILLANCE action
				if created_actions.size() == 0 or not created_actions.find(func(action): return action.action_type == Enums.ActionType.SURVEILLANCE):
					actions.append(Enums.ActionType.SURVEILLANCE)

	if (_has_plan()):
		actions.append(Enums.ActionType.PLAN)

	LogDuck.d("Opening POI radial menu", {
		"available_actions": actions,
		"owner_state": poi_owner.char_state,
		"owner_recruitment": poi_owner.char_recruitment_state
	})

	var radial_menu_instance = Globals.radial_menu_scene.instantiate()
	radial_menu_instance.position = get_local_mouse_position()
	radial_menu_instance.set_optional_actions(self, actions)
	EventBus.open_new_radial_menu.emit(radial_menu_instance)
	add_child(radial_menu_instance)
	# ReferenceGetter.game_controller().open_radial_menu(radial_menu_instance, self)

"""
@brief Handles poi focus changes.
Updates POI state based on whether its district is focused.

@param poi The newly focused POI
"""
func _on_poi_focused(poi: PointOfInterest) -> void:
	if poi == self:
		parent_district.district_clicked.emit(parent_district)

		# set the hover effect
		$IconButton.material.set_shader_parameter("enabled", true)
	else:
		# unset the hover effect
		$IconButton.material.set_shader_parameter("enabled", false)

"""
@brief Handles district focus changes.
Updates POI state based on whether its district is focused.

@param district The newly focused district
"""
func _on_district_just_focused(district: District) -> void:
	LogDuck.d("District focus changed", {
		# "district": district.district_name, #TODO: There's a bug here, why is district null?
		"is_parent": district == parent_district
	})
	
	if district == parent_district:
		$Polygon2D.color = get_poi_color()
		await get_tree().create_timer(0.01).timeout
		enabled = true
		$Polygon2D.visible = true
		$IconButton.visible = true
	else:
		await get_tree().create_timer(0.02).timeout
		$Polygon2D.color = no_color
		enabled = false
		$Polygon2D.visible = false
		$IconButton.visible = false
		$IconButton.material.set_shader_parameter("enabled", false)



"""
@brief Handles character state changes.
Updates POI popup details based on owner changes.

@param character The character whose state changed
"""
func _character_state_changed(character: Character) -> void:
	if character == poi_owner:
		poi_popup.set_details(self)

		# TODO: this doesnt work
		# if character.char_state == Enums.CharacterState.DECEASED:
		# 	$Polygon2D.color = no_color
		# 	enabled = false

"""
@brief Handles action creation events.
Updates POI state based on action creation.

@param action The action that was created
"""
func _on_action_created(action: BaseAction) -> void:
	if action.poi == self:
		LogDuck.d("Action created for POI", {
			"poi_name": poi_name,
			"action_type": action.action_type,
			"character": action.characters[0].get_full_name()
		})
		for character in action.characters:
			var action_instance = Globals.action_scene.instantiate()
			action_instance.set_meta("action_reference", action)
			action_instance.get_node("Mask/TextureRect").texture = character.char_picture
			$ActionContainer.add_child(action_instance)

"""
@brief Handles action destruction events.
Updates POI state based on action destruction.

@param action The action that was destroyed
"""
func _on_action_destroyed(action: BaseAction) -> void:
	if action.poi == self:
		LogDuck.d("Action destroyed for POI", {
			"poi_name": poi_name,
			"action_type": action.action_type
		})
		for child in $ActionContainer.get_children():
			if child.get_meta("action_reference") == action:
				child.queue_free()


func _on_open_new_radial_menu(radial_menu_instance: RadialMenu) -> void:
	# wait 0.1 seconds to ensure the radial menu is open
	await get_tree().create_timer(0.1).timeout
	$IconButton.mouse_filter = Control.MOUSE_FILTER_IGNORE


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
	var plans = ReferenceGetter.global_registry().intel.get_list(ReferenceGetter.global_registry().LIST_PLANS)
	var has_plan = false
	for plan in plans:
		if plan.plan_subject_poi == self:
			var action = ReferenceGetter.global_registry().actions.find_item(ReferenceGetter.global_registry().LIST_ALL_ACTIONS, "associated_plan", plan)
			if not action or not action.in_flight:
				has_plan = true
				break
	return has_plan

func get_poi_color() -> Color:
	if poi_owner.char_state == Enums.CharacterState.DECEASED:
		return black_color
	if poi_owner.char_recruitment_state == Enums.CharacterRecruitmentState.NON_SYMPATHISER_UNKNOWN:
		return unknown_color
	if poi_owner.char_recruitment_state == Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN:
		return known_color
	if poi_owner.char_recruitment_state == Enums.CharacterRecruitmentState.SYMPATHISER_RECRUITED:
		return sympathiser_color
	if poi_owner.char_recruitment_state == Enums.CharacterRecruitmentState.SYMPATHISER_NOT_RECRUITED:
		return sympathiser_color
	return unknown_color
		
