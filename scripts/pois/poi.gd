extends Area2D
class_name PointOfInterest

var poi_name: String = ""
var poi_description: String = ""

# Variables for scale animation
var no_color = Color(0, 0, 0, 0) # No color
var highlight_color = Color(1, 1, 1, 0.5) # Orange color

signal poi_hovered
signal poi_unhovered

func setup_poi():
	$Polygon2D.position = self.get_global_position()
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$Polygon2D.color = no_color

func set_poi_details(poi_name_arg: String, poi_description_arg: String) -> void:
	poi_name = poi_name_arg
	poi_description = poi_description_arg

# Function to expand on mouse hover
func _on_mouse_entered():
	# check if parent is focused
	# get parent of parent i.e. the root District
	var district = get_parent().get_parent()
	if get_tree().get_root().get_node('Map').district_focused != district:
		return
	$Polygon2D.color = highlight_color
	emit_signal("poi_hovered", self)

# Function to return to normal size on mouse exit
func _on_mouse_exited():
	$Polygon2D.color = no_color
	emit_signal("poi_unhovered")
