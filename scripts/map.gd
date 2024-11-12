extends Node
class_name Map

var town_name = ""

@export var footer: Control
@export var districts: Array[District] = []

func _ready() -> void:
	# get random seed
	randomize()

	footer.connect("menu_opened", _clear_focus)

	town_name = Globals.town_names[randi() % Globals.town_names.size()]

	# _set_district_details on all districts
	for district in districts:
		_set_district_details(district)
		GameController.register_district(district)

	_setup_agents()
	_generate_population()

	IntelFactory.create_rumour(IntelFactory.RumourConfig.new(100,0,0))
	IntelFactory.create_rumour(IntelFactory.RumourConfig.new(0,100,0))
	IntelFactory.create_rumour(IntelFactory.RumourConfig.new(0,0,100))


func _process(delta: float) -> void:
	if GameController.district_focused != null:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_clear_focus()

func _clear_focus() -> void:
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
	pass

func _on_poi_unhovered() -> void:
	pass

#endregion Districts

func _generate_population() -> void:

	var dead = CharacterFactory.create_character()
	var mia = CharacterFactory.create_character()

	dead.current_status = Enums.CharacterStatus.DECEASED
	mia.current_status = Enums.CharacterStatus.MIA

		
func _setup_agents() -> void:
	var population = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	var keys = population.keys()
	
	# Pick the first random key
	var random_key1 = keys[randi() % keys.size()]

	# Remove the first random key from the keys array to avoid picking it again
	keys.erase(random_key1)

	# Pick the second random key
	var random_key2 = keys[randi() % keys.size()]

	# Remove the first random key from the keys array to avoid picking it again
	keys.erase(random_key2)

	# Pick the second random key
	var random_key3 = keys[randi() % keys.size()]

	# Access the values using the random keys
	var agent1 = population[random_key1]
	var agent2 = population[random_key2]
	var agent3 = population[random_key3]
	
	agent1.sympathy = 80
	agent1.set_agent()
	agent2.sympathy = 80
	agent2.set_agent()
	agent3.set_sympathy(90)
	agent3.known = true;
