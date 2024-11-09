extends Node
class_name Map

var town_name = ""

@export var districts: Array[District] = []

func _ready() -> void:
	_generate_population()

	town_name = Globals.town_names[randi() % Globals.town_names.size()]
	$CanvasLayer/Map_Panel_Left.set_town_name(town_name)

	# _set_district_details on all districts
	for district in districts:
		_set_district_details(district)
	
	# add 4 characters 
	for i in range(4):
		var character = CharacterFactory.create_character()
		$CanvasLayer/Map_Panel_Left.add_character_card(character.id)
	
		#var whoR = IntelFactory.create_rumour(IntelFactory.RumourConfig.new(100,0,0,0))
		#var whereR = IntelFactory.create_rumour(IntelFactory.RumourConfig.new(0,100,0,0))
		#var whatR = IntelFactory.create_rumour(IntelFactory.RumourConfig.new(0,0,100,0))
		#var whenR = IntelFactory.create_rumour(IntelFactory.RumourConfig.new(0,0,0,100))

	#var plan = IntelFactory.combine_rumours([whoR, whereR, whatR, whenR])
	
	# var pois = GlobalRegistry.get_all_objects(GlobalRegistry.Registry_Category.POI)
	# var characters = GlobalRegistry.get_all_objects(GlobalRegistry.Registry_Category.CHARACTER)

	# GameController.add_action(pois[pois.keys().front()], characters[characters.keys().front()], Enums.ActionType.ESPIONAGE)

func _process(delta: float) -> void:
	if GameController.district_focused != null:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			GameController.set_district_focused()
			$Camera2D.enabled = true

#region Districts

func _set_district_details(district: District) -> void:
	var district_name = Globals.district_names[randi() % Globals.district_names.size()]
	# remove this district name from the list
	Globals.district_names.erase(Globals.district_names.find(district_name))
	var district_description = "This is the district of " + district_name + "."
	
	district.set_district_details(district_name, district_description, "")

	district.connect("district_hovered", _on_district_hovered)
	district.connect("district_unhovered", _on_district_unhovered)
	district.connect("district_clicked", _on_district_clicked)
	district.connect("poi_hovered", _on_poi_hovered)
	district.connect("poi_unhovered", _on_poi_unhovered)

func _on_district_hovered(district: District) -> void:
	if GameController.district_focused == null:
		$CanvasLayer/Map_Panel_Right.set_district_details(district)
		district.set_highlight_color()
	
func _on_district_unhovered(district: District) -> void:
	# remove highlight color if not focused
	if GameController.district_focused == null:
		district.remove_highlight_color()

func _on_district_clicked(district: District) -> void:	
	for d in districts:
		d.remove_highlight_color()
	
	district.set_focus_color()

	$Camera2D.enabled = false
	GameController.set_district_focused(district)

func _on_poi_hovered(poi: PointOfInterest) -> void:
	$CanvasLayer/Map_Panel_Right.set_poi_details(poi)

func _on_poi_unhovered() -> void:
	$CanvasLayer/Map_Panel_Right.set_poi_details()

#endregion Districts

func _generate_population() -> void:
	for i in range(10):
		CharacterFactory.create_character()
