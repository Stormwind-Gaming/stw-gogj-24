extends Node
class_name District

var district_name: String = ""
var district_description: String = ""

var heat: float = 0

var pois: Array[PointOfInterest] = []

# Colors for normal and highlight states
var normal_color = Color(0, 0, 0, 0) # No color
var highlight_color = Color(1, 0.5, 0, 0.2) # Orange color
# Red color for heat
var heat_color = Color(1, 0, 0, 0.0)

signal district_hovered(district: District)
signal district_unhovered(district: District)
signal district_clicked(district: District)
signal poi_hovered(poi: PointOfInterest)
signal poi_unhovered

func _ready() -> void:
	# set heat random 1-100
	heat = randi() % 100 + 1

	# set heat color alpha based on heat between 0 and 0.5
	heat_color.a = heat / 200

	# Set up the Polygon2D for visual appearance
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$Polygon2D.color = heat_color
	$Sprite2D.visible = false

	for poi in $pois.get_children():
		pois.append(poi)

	for poi in pois:
		poi.connect("poi_hovered", _on_poi_hovered)
		poi.connect("poi_unhovered", _on_poi_unhovered)

#region District

func set_district_details(district_name_arg: String, district_description_arg: String) -> void:
	district_name = district_name_arg
	district_description = district_description_arg

func _on_mouse_entered() -> void:
	emit_signal("district_hovered", self)
	
func _on_mouse_exited():
	emit_signal("district_unhovered", self)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
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

#endregion District

#region POIs

func _on_poi_hovered(poi: PointOfInterest) -> void:
	emit_signal("poi_hovered", poi)

func _on_poi_unhovered() -> void:
	emit_signal("poi_unhovered")

#endregion POIs
