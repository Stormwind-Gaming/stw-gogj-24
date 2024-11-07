extends Node
class_name Map

var town_name = ""

@export var district_N: District
@export var district_C_W: District
@export var district_C: District
@export var district_S_W: District

var district_focused: District = null

func _ready() -> void:
	town_name = Globals.town_names[randi() % Globals.town_names.size()]
	$CanvasLayer/Map_Panel_Left.set_town_name(town_name)

	# set the district details
	_set_district_details(district_N)
	_set_district_details(district_C)
	_set_district_details(district_C_W)
	_set_district_details(district_S_W)

func _process(delta: float) -> void:
	if district_focused != null:
		var point_to_focus_on = Vector2(800, 450) - district_focused.get_district_centerpoint()
		if $Node2D.position.distance_to(point_to_focus_on) > 1:
			# Smoothly move the position towards the target position using lerp
			$Node2D.position.x = lerp($Node2D.position.x, point_to_focus_on.x, 4 * delta)
			$Node2D.position.y = lerp($Node2D.position.y, point_to_focus_on.y, 4 * delta)

#region Districts

func _set_district_details(district: District) -> void:
	var district_name = Globals.district_names[randi() % Globals.district_names.size()]
	# remove this district name from the list
	Globals.district_names.erase(Globals.district_names.find(district_name))
	var district_description = "This is the district of " + district_name + "."
	
	# Generate a random rumour
	var rumour:Intel = IntelFactory.create_rumour(25,25,25,25)
	
	district.set_district_details(district_name, district_description, rumour.description)

	district.connect("district_hovered", _on_district_hovered)
	district.connect("district_unhovered", _on_district_unhovered)
	district.connect("district_clicked", _on_district_clicked)
	district.connect("poi_hovered", _on_poi_hovered)
	district.connect("poi_unhovered", _on_poi_unhovered)

func _on_district_hovered(district: District) -> void:
	if district_focused == null:
		$CanvasLayer/Map_Panel_Right.set_district_details(district)
		district.set_highlight_color()
	
func _on_district_unhovered(district: District) -> void:
	if district_focused == null:
		district.remove_highlight_color()

func _on_district_clicked(district: District) -> void:
	if district_focused != null:
		district_focused = null
		$Node2D.enabled = true
		return
		
	$Node2D.enabled = false
	district_focused = district
	

func _on_poi_hovered(poi: PointOfInterest) -> void:
	$CanvasLayer/Map_Panel_Right.set_poi_details(poi)

func _on_poi_unhovered() -> void:
	$CanvasLayer/Map_Panel_Right.set_poi_details()

#endregion Districts
