extends Node
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
var heat: float = 0

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
	# emit district created signal
	EventBus.district_created.emit(self)
	EventBus.district_heat_changed.connect(_update_heat_value)
	EventBus.character_sympathy_changed.connect(_update_sympathy_value)

	# set heat random between min and max
	heat = MathHelpers.generateBellCurveStat(Constants.DISTRICT_INIT_HEAT_MIN, Constants.DISTRICT_INIT_HEAT_MAX)

	# set heat color alpha based on heat between 0 and 0.5
	heat_color.a = heat / 200

	# Set up the Polygon2D for visual appearance
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$Polygon2D.color = heat_color
	$Sprite2D.visible = false

	for poi in $pois.get_children():
		pois.append(poi)

	for poi in pois:
		# connect signals
		poi.connect("poi_hovered", _on_poi_hovered)
		poi.connect("poi_unhovered", _on_poi_unhovered)
		# setup visuals
		poi.setup_poi_visuals()

		if poi.poi_static:
			poi.set_poi_details(self, Enums.POIType.NONE, "", "")
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

		# set the poi details
		poi.set_poi_details(self, selected_poi_type["poi_type"], "%s - %s" % [poi_name, selected_poi_type["poi_name"]], selected_poi_type["poi_description"])

"""
@brief Called every frame to update district state.
Handles popup visibility based on hover state.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	if hovered and !GameController.district_focused:
		district_popup.visible = true
		district_popup.set_position(get_viewport().get_mouse_position() + Vector2(10, 10))
	else:
		district_popup.visible = false

"""
@brief updates heat value and visuals

@param district The district to update 
new_heat The new heat value
"""
func _update_heat_value(district: District, new_heat: float) -> void:
	if district == self:
		heat += new_heat
		heat_color.a = heat / 200
		$Polygon2D.color = heat_color
	district_popup.set_heat(heat)

"""
@brief updates sympathy value and visuals

@param character The character to update
"""
func _update_sympathy_value(character: Character) -> void:
	# TODO: for some reason this efficiency enhancement isnt working
	# if this character is not in this district, return
	# for poi in pois:
	# 	if poi.poi_owner == character:
	# 		print("Character found")
	var total_sympathy = 0
	for p in pois:
		total_sympathy += p.poi_owner.char_sympathy
	sympathy = total_sympathy / pois.size()
	district_popup.set_sympathy(sympathy)
			# return


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
	district_name = district_name_arg
	district_description = district_description_arg
	rumour_text = rumour_text_arg

	district_popup.set_initial_details("%s %s District" % [district_name, Globals.get_district_type_string(district_type)], "%s\n\nType: %s\n%s Points of Interest" % [district_description, Globals.get_district_type_string(district_type), str(pois.size())], heat, sympathy)

"""
@brief Gets the center point of the district.

@returns Vector2 position of the district's center
"""
func get_district_centerpoint() -> Vector2:
	return $FocusPoint.position

"""
@brief Sets the highlight color for the district
"""
func set_highlight_color() -> void:
	$Polygon2D.color = highlight_color

"""
@brief Removes the highlight color and shows heat color
"""
func remove_highlight_color() -> void:
	$Polygon2D.color = heat_color

"""
@brief Sets the focus color for the district
"""
func set_focus_color() -> void:
	$Polygon2D.color = no_color

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles mouse enter events.
Updates visual state and emits hover signal.
"""
func _on_mouse_entered() -> void:
	# check if we have a radial menu instance, if so, don't expand
	if GameController.radial_menu_open != null or GameController.menus_open:
		return
	
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
	if GameController.radial_menu_open != null or GameController.menus_open:
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
