extends Node
class_name Map

#|==============================|
#|         Properties          |
#|==============================|

"""
@brief Reference to the footer UI control
"""
@export var footer: Control

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Initializes the map, districts, and starting agents.
"""
func _ready() -> void:
	randomize()
	footer.connect("menu_opened", _clear_focus)
	GameController.set_town_name(Globals.town_names[randi() % Globals.town_names.size()])
	EventBus.end_turn_initiated.connect(_clear_focus)
	EventBus.open_new_window.connect(_clear_focus)

	for district in GlobalRegistry.districts.get_all_items():
		_set_district_details(district)

	_setup_agents()
	_generate_population()

	# Create initial rumours
	IntelFactory.create_rumour(RumourConfig.new(100,0,0))
	IntelFactory.create_rumour(RumourConfig.new(0,100,0))
	IntelFactory.create_rumour(RumourConfig.new(0,0,100))

"""
@brief Called every frame to handle input.
Checks for middle/right click to clear district focus.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	if GameController.district_focused != null:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_clear_focus()

#|==============================|
#|      District Management    |
#|==============================|
"""
@brief Clears the currently focused district
"""
func _clear_focus(_i = null) -> void:
	print("Clearing focus")
	GameController.set_district_focused(null)
	$Camera2D.enabled = true

"""
@brief Sets up a district with random name and description

@param district The district to initialize
"""
func _set_district_details(district: District) -> void:
	var district_name = Globals.district_names[randi() % Globals.district_names.size()]
	Globals.district_names.erase(Globals.district_names.find(district_name))
	var district_description = "This is the district of " + district_name + "."
	
	district.set_district_details(district_name, district_description, "")
	_connect_district_signals(district)

"""
@brief Connects signal handlers for district events

@param district The district to connect signals for
"""
func _connect_district_signals(district: District) -> void:
	district.connect("district_hovered", _on_district_hovered)
	district.connect("district_unhovered", _on_district_unhovered)
	district.connect("district_clicked", _on_district_clicked)
	district.connect("poi_hovered", _on_poi_hovered)
	district.connect("poi_unhovered", _on_poi_unhovered)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles district hover events
@param district The district being hovered
"""
func _on_district_hovered(district: District) -> void:
	if GameController.district_focused == null:
		district.set_highlight_color()

"""
@brief Handles district unhover events
@param district The district being unhovered
"""
func _on_district_unhovered(district: District) -> void:
	if GameController.district_focused == null:
		district.remove_highlight_color()

"""
@brief Handles district click events
@param district The district being clicked
"""
func _on_district_clicked(district: District) -> void:    
	for d in GlobalRegistry.districts.get_all_items():
		d.remove_highlight_color()
	
	district.set_focus_color()
	$Camera2D.enabled = false
	GameController.set_district_focused(district)

"""
@brief Handles POI hover events
@param poi The POI being hovered
"""
func _on_poi_hovered(poi: PointOfInterest) -> void:
	pass

"""
@brief Handles POI unhover events
"""
func _on_poi_unhovered() -> void:
	pass

#|==============================|
#|      Character Setup        |
#|==============================|
"""
@brief Generates initial population including some special cases
"""
func _generate_population() -> void:
	var dead = CharacterFactory.create_character()
	var mia = CharacterFactory.create_character()

	dead.char_state = Enums.CharacterState.DECEASED
	mia.char_state = Enums.CharacterState.MIA

"""
@brief Sets up initial agent characters with high sympathy
"""
func _setup_agents() -> void:
	var population = GlobalRegistry.characters.get_all_items()
	
	# Pick three random characters to be initial agents
	var agent1 = population[randi() % population.size()]
	population.erase(agent1)
	var agent2 = population[randi() % population.size()]
	population.erase(agent2)
	var agent3 = population[randi() % population.size()]
	
	agent1.char_sympathy = 80
	agent1.char_recruitment_state = Enums.CharacterRecruitmentState.SYMPATHISER_RECRUITED
	agent2.char_sympathy = 80
	agent2.char_recruitment_state = Enums.CharacterRecruitmentState.SYMPATHISER_RECRUITED
	agent3.char_sympathy = 90
