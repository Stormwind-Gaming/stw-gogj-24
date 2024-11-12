extends Node
class_name District

@export var district_popup: Window

var district_type: Enums.DistrictType
var district_name: String = ""
var district_description: String = ""
var rumour_text: String = ""

var heat: float = 0

var pois: Array[PointOfInterest] = []

# Colors for normal and highlight states
var no_color = Color(0, 0, 0, 0) # No color
var highlight_color = Color(1, 0.5, 0, 0.2) # Orange color
# Red color for heat
var heat_color = Color(1, 0, 0, 0.0)

var hovered: bool = false

signal district_hovered(district: District)
signal district_unhovered(district: District)
signal district_clicked(district: District)
signal poi_hovered(poi: PointOfInterest)
signal poi_unhovered

func _ready() -> void:
	# Give the district a random type
	district_type = randi() % Enums.DistrictType.size() as Enums.DistrictType

	# set heat random 20-80
	heat = randi() % 80 + 21

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

func _process(delta: float) -> void:
	if hovered and !GameController.district_focused:
		district_popup.visible = true
		district_popup.set_position(get_viewport().get_mouse_position() + Vector2(10, 10))
	else:
		district_popup.visible = false

#region District

func set_district_details(district_name_arg: String, district_description_arg: String, rumour_text_arg: String) -> void:
	district_name = district_name_arg
	district_description = district_description_arg
	rumour_text = rumour_text_arg

	district_popup.set_details(district_name, "%s\n\nType: %s\n%s Points of Interest\n\nHeat: [font_size=20]%s[/font_size]" % [district_description, Globals.get_district_type_string(district_type), str(pois.size()), str(heat)  + "%"])

func _on_mouse_entered() -> void:
	# check if we have a radial menu instance, if so, don't expand
	if GameController.radial_menu_open != null or GameController.menus_open:
		return
	
	hovered = true
		
	emit_signal("district_hovered", self)
	
func _on_mouse_exited():
	hovered = false
	emit_signal("district_unhovered", self)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# check if we have a radial menu instance, if so, don't expand
	if GameController.radial_menu_open != null or GameController.menus_open:
		return

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			emit_signal("district_clicked", self)

func get_district_centerpoint() -> Vector2:
	return $FocusPoint.position

func set_highlight_color() -> void:
	$Polygon2D.color = highlight_color

func remove_highlight_color() -> void:
	$Polygon2D.color = heat_color

func set_focus_color() -> void:
	$Polygon2D.color = no_color
#endregion District

#region POIs

func _on_poi_hovered(poi: PointOfInterest) -> void:
	emit_signal("poi_hovered", poi)

func _on_poi_unhovered() -> void:
	emit_signal("poi_unhovered")

#endregion POIs
