extends NodeWithCleanup

class_name District

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Popup window for district information
"""
@export var district_popup: Window

"""
@brief Type of district (residential, commercial, etc.)
"""
@export var district_type: Enums.DistrictType

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Name of the district
"""
var district_name: String = ""

"""
@brief Description of the district
"""
var district_description: String = ""

"""
@brief Text for any rumours associated with this district
"""
var rumour_text: String = ""

"""
@brief Heat level of the district (attention from authorities)
"""
var heat: set = set_heat

"""
@brief Sympathy level of the district (aggregate of all characters from PoIs)
"""
var sympathy: float = 0

"""
@brief Array of Points of Interest in this district
"""
var pois: Array[PointOfInterest] = []

"""
@brief Visual state colors
"""
var no_color = Color(0, 0, 0, 0) # No color
var highlight_color = Color(1, 0.5, 0, 0.2) # Orange color
var heat_color = Color(1, 0, 0, 0.0) # Red color for heat

"""
@brief Whether the mouse is currently hovering over this district
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
@brief Emitted when mouse enters district area
"""
signal district_hovered(district: District)

"""
@brief Emitted when mouse exits district area
"""
signal district_unhovered(district: District)

"""
@brief Emitted when district is clicked
"""
signal district_clicked(district: District)

"""
@brief Emitted when mouse enters a POI in this district
"""
signal poi_hovered(poi: PointOfInterest)

"""
@brief Emitted when mouse exits a POI in this district
"""
signal poi_unhovered

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Initializes district properties and sets up POIs.
"""
func _ready() -> void:
	if gui_debug:
		LogDuck.d("District: Initializing district")

	# emit district created signal
	EventBus.district_created.emit(self)
	EventBus.character_sympathy_changed.connect(_update_sympathy_value)
	EventBus.district_unfocused.connect(_reset_highlight_color)

	# Setup the district modifiers
	if gui_debug:
		LogDuck.d("District: Setting up modifiers")
	_setup_modifiers()

	# set heat random between min and max
	heat = MathHelpers.generate_bell_curve_stat(Constants.DISTRICT_INIT_HEAT_MIN, Constants.DISTRICT_INIT_HEAT_MAX)

	# set heat color alpha based on heat between 0 and 0.5
	heat_color.a = float(heat) / 200.0

	# Set up the Polygon2D for visual appearance
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$Polygon2D.color = heat_color
	$Sprite2D.visible = false

	if gui_debug:
		LogDuck.d("District: Setting up POIs")
	for poi in $pois.get_children():
		if poi.visible:
			# get the pois that are visible (enabled)
			pois.append(poi)

	for poi in pois:
		# connect signals
		poi.connect("poi_hovered", _on_poi_hovered)
		poi.connect("poi_unhovered", _on_poi_unhovered)
		# setup visuals
		poi.setup_poi_visuals()

		if poi.poi_static:
			if gui_debug:
				LogDuck.d("District: Setting up static POI")
			poi.set_poi_details(self, Enums.POIType.NONE, "", "", "", "", 1, 1, 1)
			continue

		# get a random poi type
		var poi_types = Globals.get_poi_types(district_type)

		# if a POI has a spawn chance of 100, it will always spawn, so we need to check if we already have the max of that type
		var guaranteed_poi_types = poi_types.filter(
			func(poi_type):
				return poi_type["spawn_chance"] == 100
		).filter(
			func(poi_type):
				return pois.filter(
					func(poi_to_filter):
						return poi_to_filter.poi_type == poi_type["poi_type"]
				).size() < poi_type["max_spawn_quantity"]
		)
		
		var selected_poi_type = null
		if guaranteed_poi_types.size() > 0:
			selected_poi_type = guaranteed_poi_types[0]
		else:
			# filter poi types by if they have a max_spawn_quantity and if we already have the max of that type
			var filtered_poi_types = poi_types.filter(
				func(poi_type):
					if poi_type["max_spawn_quantity"] == -1:
						return true
					else:
						return pois.filter(
							func(poi_to_filter):
								return poi_to_filter.poi_type == poi_type["poi_type"]
						).size() < poi_type["max_spawn_quantity"]
			)
			# get a random poi type from the filtered list based on spawn_chance by adding all spawn chances together
			var total_spawn_chance = 0
			for poi_type in filtered_poi_types:
				total_spawn_chance += poi_type["spawn_chance"]
			var random_spawn_chance = randi_range(0, total_spawn_chance)

			# get the poi type based on the random spawn chance
			var current_spawn_chance = 0
			for poi_type in filtered_poi_types:
				current_spawn_chance += poi_type["spawn_chance"]
				if random_spawn_chance <= current_spawn_chance:
					selected_poi_type = poi_type
					break

		# if we didn't find a poi type, return
		if selected_poi_type == null:
			print("No poi type found")
			return
		
		# get the poi name by type
		var poi_name = Globals.get_poi_name(selected_poi_type["poi_type"])

		# if poi name is the same as another poi in the district, get a new name
		while pois.filter(
			func(poi_to_filter):
				return poi_to_filter.poi_name == "%s - %s" % [poi_name, selected_poi_type["poi_name"]]
		).size() > 0:
			print("Duplicate poi name found")
			poi_name = Globals.get_poi_name(selected_poi_type["poi_type"])

		# set the poi details
		poi.set_poi_details(self, selected_poi_type["poi_type"], "%s - %s" % [poi_name, selected_poi_type["poi_name"]], selected_poi_type["poi_profession"], selected_poi_type["poi_short_description"], selected_poi_type["poi_description"], selected_poi_type["what_chance"], selected_poi_type["where_chance"], selected_poi_type["when_chance"])

"""
@brief Called every frame to update district state.
Handles popup visibility based on hover state.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	if hovered and !ReferenceGetter.game_controller().district_focused:
		district_popup.visible = true
		district_popup.set_position(get_viewport().get_mouse_position() + Vector2(10, 10))
	else:
		district_popup.visible = false

"""
@brief updates heat value and visuals

@param district The district to update
new_heat The new heat value
"""
# func _update_heat_value(district: District, new_heat: int) -> void:
# 	if district == self:
# 		heat += new_heat
# 		heat_color.a = heat / 200
# 		$Polygon2D.color = heat_color
# 	district_popup.set_heat(heat)

"""
@brief updates sympathy value and visuals

@param character The character to update
"""
func _update_sympathy_value(character: Character) -> void:
	if gui_debug:
		LogDuck.d("District: Updating sympathy value for character %s" % character.char_full_name)
	var total_sympathy = 0
	for p in pois:
		total_sympathy += p.poi_owner.char_sympathy
	sympathy = total_sympathy / pois.size()
	if gui_debug:
		LogDuck.d("District: New sympathy value: %f" % sympathy)
	district_popup.set_sympathy(sympathy)

func _setup_modifiers() -> void:
	if gui_debug:
		LogDuck.d("District: Setting up modifiers for district type: %s" % Globals.get_district_type_string(district_type))
	match district_type:

		# Military district modifiers
		Enums.DistrictType.MILITARY:
			if gui_debug:
				LogDuck.d("District: Setting up military district modifiers")
			var _base_military_district_modifier: Modifier = Modifier.new({
				"scope": Enums.ModifierScope.DISTRICT,
				"district": self,
				"modifier_name": "Military District Effect"
			}, {
				"modifier_sympathy_multiplier": Constants.MILITARY_DISTRICT_MODIFIER_BASE
			})

			# First create the variable
			var _bonus_military_district_modifier: Modifier
			
			# Define the closure separately
			var military_closure = func(mod: Modifier):
				var is_active = sympathy > Constants.MILITARY_DISTRICT_BONUS_BREAKPOINT
				if is_active and not mod.active:
					EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.EVENT_MILITARY_MILESTONE, [] as Array[Character], self.pois[0])
				return is_active

			# Then create the modifier
			_bonus_military_district_modifier = Modifier.new({
				"scope": Enums.ModifierScope.WORLD,
				"district": self,
				"modifier_name": "Military District Modifier",
				"active": false,
			}, {
				"modifier_subtlety_flat": Constants.MILITARY_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
			})

			# Set the closure to the modifier
			_bonus_military_district_modifier.modifier_active_closure = military_closure.bind(_bonus_military_district_modifier)

		# Civic district modifiers
		Enums.DistrictType.CIVIC:
			if gui_debug:
				LogDuck.d("District: Setting up civic district modifiers")
			var _base_civic_district_modifier: Modifier = Modifier.new({
				"scope": Enums.ModifierScope.DISTRICT,
				"district": self,
				"modifier_name": "Civic District Effect"
			}, {
				"modifier_heat_multiplier": Constants.CIVIC_DISTRICT_MODIFIER_BASE
			})

			# First create the variable
			var _bonus_civic_district_modifier: Modifier
			
			# Define the closure separately
			var civic_closure = func(mod: Modifier):
				var is_active = sympathy > Constants.CIVIC_DISTRICT_BONUS_BREAKPOINT
				if is_active and not mod.active:
					EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.EVENT_CIVIC_MILESTONE, [] as Array[Character], self.pois[0])
				return is_active

			# Then create the modifier
			_bonus_civic_district_modifier = Modifier.new({
				"scope": Enums.ModifierScope.WORLD,
				"district": self,
				"modifier_name": "Civic District Modifier",
				"active": false,
			}, {
				"modifier_charm_flat": Constants.CIVIC_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
			})

			# Set the closure to the modifier
			_bonus_civic_district_modifier.modifier_active_closure = civic_closure.bind(_bonus_civic_district_modifier)

		# Industrial district modifiers
		Enums.DistrictType.INDUSTRIAL:
			if gui_debug:
				LogDuck.d("District: Setting up industrial district modifiers")
			var _base_industrial_district_modifier: Modifier = Modifier.new({
				"scope": Enums.ModifierScope.DISTRICT,
				"district": self,
				"modifier_name": "Industrial District Effect"
			}, {
				"modifier_consequence_multiplier": Constants.INDUSTRIAL_DISTRICT_MODIFIER_BASE
			})

			# First create the variable
			var _bonus_industrial_district_modifier: Modifier
			
			# Define the closure separately
			var industrial_closure = func(mod: Modifier):
				var is_active = sympathy > Constants.INDUSTRIAL_DISTRICT_BONUS_BREAKPOINT
				if is_active and not mod.active:
					EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.EVENT_INDUSTRIAL_MILESTONE, [] as Array[Character], self.pois[0])
				return is_active

			# Then create the modifier
			_bonus_industrial_district_modifier = Modifier.new({
				"scope": Enums.ModifierScope.WORLD,
				"district": self,
				"modifier_name": "Industrial District Modifier",
				"active": false,
			}, {
				"modifier_smarts_flat": Constants.INDUSTRIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
			})

			# Set the closure to the modifier
			_bonus_industrial_district_modifier.modifier_active_closure = industrial_closure.bind(_bonus_industrial_district_modifier)

		# Residential district modifiers
		Enums.DistrictType.RESIDENTIAL:
			var _base_residential_district_modifier: Modifier = Modifier.new({
				"scope": Enums.ModifierScope.DISTRICT,
				"district": self,
				"modifier_name": "Residential District Effect"
			}, {
				"modifier_subtlety_multiplier": Constants.RESIDENTIAL_DISTRICT_MODIFIER_BASE
			})

			# First create the variable
			var _bonus_residential_district_modifier: Modifier
			
			# Define the closure separately
			var residential_closure = func(mod: Modifier):
				var is_active = sympathy > Constants.RESIDENTIAL_DISTRICT_BONUS_BREAKPOINT
				if is_active and not mod.active:
					EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.EVENT_RESIDENTIAL_MILESTONE, [] as Array[Character], self.pois[0])
				return is_active
			
			# Then create the modifier
			_bonus_residential_district_modifier = Modifier.new({
				"scope": Enums.ModifierScope.WORLD,
				"district": self,
				"modifier_name": "Residential District Modifier",
				"active": false,
			}, {
				"modifier_sympathy_multiplier": Constants.RESIDENTIAL_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
			})

			# Set the closure to the modifier
			_bonus_residential_district_modifier.modifier_active_closure = residential_closure.bind(_bonus_residential_district_modifier)
		
		# Port district modifiers
		Enums.DistrictType.PORT:
			if gui_debug:
				LogDuck.d("District: Setting up port district modifiers")
			var _base_port_district_modifier: Modifier = Modifier.new({
				"scope": Enums.ModifierScope.DISTRICT,
				"district": self,
				"modifier_name": "Port District Effect"
			}, {
				"modifier_action_duration_flat": Constants.PORT_DISTRICT_MODIFIER_BASE
			})

			# First create the variable
			var _bonus_port_district_modifier: Modifier
			
			# Define the closure separately
			var port_closure = func(mod: Modifier):
				var is_active = sympathy > Constants.PORT_DISTRICT_BONUS_BREAKPOINT
				if is_active and not mod.active:
					EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.EVENT_PORT_MILESTONE, [] as Array[Character], self.pois[0])
				return is_active
			
			# Then create the modifier
			_bonus_port_district_modifier = Modifier.new({
				"scope": Enums.ModifierScope.WORLD,
				"district": self,
				"modifier_name": "Port District Modifier",
				"active": false,
			}, {
				"modifier_heat_multiplier": Constants.PORT_DISTRICT_MODIFIER_HIGH_SYMPATHY_VALUE
			})

			# Set the closure to the modifier
			_bonus_port_district_modifier.modifier_active_closure = port_closure.bind(_bonus_port_district_modifier)

#|==============================|
#|      District Methods        |
#|==============================|
"""
@brief Sets the district's details and updates the popup information.

@param district_name_arg The name of the district
@param district_description_arg The description of the district
@param rumour_text_arg Any rumours associated with the district
"""
func set_district_details(district_name_arg: String, district_description_arg: String, rumour_text_arg: String) -> void:
	if gui_debug:
		LogDuck.d("District: Setting district details - Name: %s" % district_name_arg)
	district_name = district_name_arg
	district_description = district_description_arg
	rumour_text = rumour_text_arg

	district_popup.set_initial_details("%s %s District" % [district_name, Globals.get_district_type_string(district_type)], "%s\n\nType: %s\n%s Points of Interest" % [district_description, Globals.get_district_type_string(district_type), str(pois.size())], heat, sympathy)

"""
@brief Gets the center point of the district based on the polygon's center.

@returns Vector2 position of the district's center
"""
func get_district_centerpoint() -> Vector2:
	return $FocusPoint.position
	# var polygon = $CollisionPolygon2D.polygon
	# if polygon.size() == 0:
	# 	return Vector2.ZERO
		
	# # Calculate the center by averaging all points
	# var center = Vector2.ZERO
	# for point in polygon:
	# 	center += point
	# center /= polygon.size()
	
	# # Add the district's global position to get world coordinates
	# return self.global_position + center

"""
@brief Sets the highlight color for the district
"""
func set_highlight_color() -> void:
	if gui_debug:
		LogDuck.d("District: Setting highlight color")
	$Polygon2D.color = highlight_color

"""
@brief Removes the highlight color and shows heat color
"""
func remove_highlight_color() -> void:
	if gui_debug:
		LogDuck.d("District: Removing highlight color")
	$Polygon2D.color = heat_color

"""
@brief Sets the focus color for the district
"""
func set_focus() -> void:
	if gui_debug:
		LogDuck.d("District: Setting focus")
	$Polygon2D.visible = false
	$CollisionPolygon2D.visible = false

"""
@brief Unsets the focus color for the district
"""
func unset_focus() -> void:
	if gui_debug:
		LogDuck.d("District: Unsetting focus")
	$Polygon2D.visible = true
	$CollisionPolygon2D.visible = true

"""
@brief Sets the district as disabled
"""
func set_disabled() -> void:
	$CollisionPolygon2D.disabled = true

"""
@brief Sets the district as enabled
"""
func set_enabled() -> void:
	$CollisionPolygon2D.disabled = false

"""
@brief Gets the size of the district based on its collision polygon.

@returns Vector2 containing the width and height of the district
"""
func get_district_size() -> Vector2:
	var polygon = $CollisionPolygon2D.polygon
	if polygon.size() == 0:
		return Vector2.ZERO
		
	# Find the minimum and maximum coordinates
	var min_x = polygon[0].x
	var max_x = polygon[0].x
	var min_y = polygon[0].y
	var max_y = polygon[0].y
	
	for point in polygon:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	# Return the size as width and height
	return Vector2(max_x - min_x, max_y - min_y)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles mouse enter events.
Updates visual state and emits hover signal.
"""
func _on_mouse_entered() -> void:
	if WindowHandler.any_windows_open():
		if gui_debug:
			LogDuck.d("District: Mouse entered ignored due to open menu/window")
		return
	
	if gui_debug:
		LogDuck.d("District: Mouse entered")
	hovered = true
	emit_signal("district_hovered", self)

"""
@brief Handles mouse exit events.
Updates visual state and emits unhover signal.
"""
func _on_mouse_exited():
	hovered = false
	emit_signal("district_unhovered", self)

"""
@brief Handles input events on the district.
Processes clicks and emits signals.

@param viewport The viewport that received the event
@param event The input event
@param shape_idx The shape index that was clicked
"""
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# check if we have a radial menu instance, if so, don't expand
	if WindowHandler.any_windows_open():
		return

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			emit_signal("district_clicked", self)

"""
@brief Handles POI hover events.
Forwards POI hover signals.

@param poi The POI being hovered
"""
func _on_poi_hovered(poi: PointOfInterest) -> void:
	emit_signal("poi_hovered", poi)

"""
@brief Handles POI unhover events.
Forwards POI unhover signals.
"""
func _on_poi_unhovered() -> void:
	emit_signal("poi_unhovered")

func _reset_highlight_color(district: District) -> void:
	if district == self:
		$Polygon2D.color = heat_color
		$Polygon2D.visible = true
		$CollisionPolygon2D.visible = true

#|==============================|
#|      Setters                |
#|==============================|

func set_heat(new_heat: int) -> void:
	if gui_debug:
		LogDuck.d("District: Setting heat to %d" % new_heat)
	heat = clamp(new_heat, 0, 100)
	district_popup.set_heat(heat)
	heat_color.a = float(heat) / 200.0
	$Polygon2D.color = heat_color
	if gui_debug:
		LogDuck.d("District: Heat color alpha set to %f" % heat_color.a)
