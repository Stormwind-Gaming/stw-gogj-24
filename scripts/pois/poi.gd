extends Area2D
class_name PointOfInterest

var poi_name: String = ""
var poi_description: String = ""

# Variables for scale animation
var normal_scale = Vector2(0.3, 0.3)
var hover_scale = Vector2(0.4, 0.4)  # Slightly larger scale

signal poi_hovered
signal poi_unhovered

func _ready():
	$Sprite2D.scale = normal_scale

func set_poi_details(poi_name_arg: String, poi_description_arg: String) -> void:
	poi_name = poi_name_arg
	poi_description = poi_description_arg

# Function to expand on mouse hover
func _on_mouse_entered():
	$Sprite2D.scale = hover_scale
	emit_signal("poi_hovered", self)

# Function to return to normal size on mouse exit
func _on_mouse_exited():
	$Sprite2D.scale = normal_scale
	emit_signal("poi_unhovered")
