extends Node
class_name Map

var town_name = ""

@export var districts: Array[District] = []

var district_focused: District = null

func _ready() -> void:
	town_name = Globals.town_names[randi() % Globals.town_names.size()]
	$CanvasLayer/Map_Panel_Left.set_town_name(town_name)

	# _set_district_details on all districts
	for district in districts:
		_set_district_details(district)
	
	# add 4 characters 
	for i in range(4):
		var character = GlobalRegistry.register_object(GlobalRegistry.Registry_Category.CHARACTER, CharacterFactory.create_character())
		$CanvasLayer/Map_Panel_Left.add_character_card(character)

#region Districts

func _set_district_details(district: District) -> void:
	var district_name = Globals.district_names[randi() % Globals.district_names.size()]
	# remove this district name from the list
	Globals.district_names.erase(Globals.district_names.find(district_name))
	var district_description = "This is the district of " + district_name + "."
	
	# Generate a random rumour
	var rumour: Intel = IntelFactory.create_rumour(25,25,25,25)
	
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
	# remove highlight color if not focused
	if district_focused == null:
		district.remove_highlight_color()

func _on_district_clicked(district: District) -> void:
	if district_focused != null:
		district_focused = null
		$Camera2D.enabled = true
		district.set_highlight_color()
		
		return
	
	for d in districts:
		d.remove_highlight_color()
	
	district.set_focus_color()

	$Camera2D.enabled = false
	district_focused = district

func _on_poi_hovered(poi: PointOfInterest) -> void:
	$CanvasLayer/Map_Panel_Right.set_poi_details(poi)

func _on_poi_unhovered() -> void:
	$CanvasLayer/Map_Panel_Right.set_poi_details()

#endregion Districts
