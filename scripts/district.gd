extends Node
class_name District

var district_name: String = ""
var district_description: String = ""

var pois: Array[PointOfInterest] = []

# Colors for normal and highlight states
var normal_color = Color(0, 0, 0, 0) # No color
var highlight_color = Color(1, 0.5, 0, 0.2) # Orange color

signal district_hovered(district: District)
signal poi_hovered(poi: PointOfInterest)
signal poi_unhovered

func _ready() -> void:
	# Set up the Polygon2D for visual appearance
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$Polygon2D.color = normal_color
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
	$Polygon2D.color = highlight_color

func _on_mouse_exited():
	$Polygon2D.color = normal_color

#endregion District

#region POIs

func _on_poi_hovered(poi: PointOfInterest) -> void:
	emit_signal("poi_hovered", poi)

func _on_poi_unhovered() -> void:
	emit_signal("poi_unhovered")

#endregion POIs
