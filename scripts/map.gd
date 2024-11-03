extends Node
class_name Map

var town_name = ""

@export var district_N_E: District
@export var district_S_E: District
@export var district_S_W: District
@export var district_N_W: District

func _ready() -> void:
	town_name = Globals.town_names[randi() % Globals.town_names.size()]
	$CanvasLayer/Map_Panel_Left.set_town_name(town_name)

	# set the district details
	_set_district_details(district_N_E)
	_set_district_details(district_S_E)
	_set_district_details(district_S_W)
	_set_district_details(district_N_W)

#region Districts

func _set_district_details(district: District) -> void:
	var district_name = Globals.district_names[randi() % Globals.district_names.size()]
	# remove this district name from the list
	Globals.district_names.erase(Globals.district_names.find(district_name))
	var district_description = "This is the district of " + district_name + "."
	district.set_district_details(district_name, district_description)

	district.connect("district_hovered", _on_district_clicked)
	district.connect("poi_hovered", _on_poi_hovered)
	district.connect("poi_unhovered", _on_poi_unhovered)

func _on_district_clicked(district: District) -> void:
	$CanvasLayer/Map_Panel_Right.set_district_details(district)

func _on_poi_hovered(poi: PointOfInterest) -> void:
	$CanvasLayer/Map_Panel_Right.set_poi_details(poi)

func _on_poi_unhovered() -> void:
	$CanvasLayer/Map_Panel_Right.set_poi_details()

#endregion Districts
