extends Node
class_name Map

#|==============================|
#|         Properties          |
#|==============================|

"""
@brief Reference to the pause_menu UI control
"""
@export var pause_menu: Window

"""
@brief Reference to the footer UI control
"""
@export var footer: Control

"""
@brief Reference to the stats panel
"""
@export var stats_panel: PanelContainer

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Initializes the map, districts, and starting agents.
"""
func _ready() -> void:
	randomize()
	GameController.set_town_name(Globals.town_names[randi() % Globals.town_names.size()])
	EventBus.end_turn_initiated.connect(_clear_focus)
	EventBus.open_new_window.connect(_disable_interaction)
	EventBus.close_all_windows.connect(_enable_interaction)
	EventBus.game_over.connect(_game_over)

	for district in GlobalRegistry.districts.get_all_items():
		_set_district_details(district)

	_setup_agents()
	_generate_population()

	# Create initial rumours
	IntelFactory.create_rumour(RumourConfig.new(100, 0, 0))
	IntelFactory.create_rumour(RumourConfig.new(0, 100, 0))
	IntelFactory.create_rumour(RumourConfig.new(0, 0, 100))

"""
@brief Called every frame to handle input.
Checks for middle/right click to clear district focus.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	if GameController.district_focused != null:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_clear_focus()
	if Input.is_action_just_pressed("ui_cancel"):
		# EventBus.close_all_windows.emit()
		if pause_menu.visible:
			pause_menu.hide()
		else:
			pause_menu.show()
		pass
		# open pause menu
	if Input.is_action_just_pressed("open_stats_panel"):
		stats_panel.visible = not stats_panel.visible


#|==============================|
#|      District Management    |
#|==============================|
"""
@brief Clears the currently focused district
"""
func _clear_focus(_i = null) -> void:
	EventBus.district_unfocused.emit(GameController.district_focused)
	GameController.set_district_focused(null)
	$Camera2D.camera_enabled = true

	## Enabling clouds and sound
	# Access the material and shader
	var material = $Clouds.material
	# Create a tween to animate the shader's alpha_multiplier property
	var clouds_tween = create_tween()
	clouds_tween.tween_property(material, "shader_parameter/alpha_multiplier", 0.7, 1.0).set_ease(Tween.EASE_IN)

	var wind_tween = create_tween()
	wind_tween.tween_property($WindEffect, "volume_db", 0, 1.0).set_ease(Tween.EASE_IN)

	var street_tween = create_tween()
	street_tween.tween_property($StreetEffect, "volume_db", -80, 1.0).set_ease(Tween.EASE_OUT)

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
		d.unset_focus()
	
	district.set_focus()
	$Camera2D.camera_enabled = false
	GameController.set_district_focused(district)

	## Disabling clouds and sound
	# Access the material and shader
	var material = $Clouds.material
	# Create a tween to animate the shader's alpha_multiplier property
	var clouds_tween = create_tween()
	clouds_tween.tween_property(material, "shader_parameter/alpha_multiplier", 0.0, 1.0).set_ease(Tween.EASE_IN)

	var wind_tween = create_tween()
	wind_tween.tween_property($WindEffect, "volume_db", -80, 1.0).set_ease(Tween.EASE_OUT)

	var street_tween = create_tween()
	street_tween.tween_property($StreetEffect, "volume_db", -10, 1.0).set_ease(Tween.EASE_IN)



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

"""
@brief Disables interaction with the map
"""
func _disable_interaction(_i = 0) -> void:
	for district in GlobalRegistry.districts.get_all_items():
		district.set_disabled()
	pass

"""
@brief Enables interaction with the map
"""
func _enable_interaction() -> void:
	for district in GlobalRegistry.districts.get_all_items():
		district.set_enabled()
	_clear_focus()

"""
@brief Handles game over event
"""
func _game_over() -> void:
	_disable_interaction(0)
	$AnimationPlayer.play("fade_out")
	$AnimationPlayer.animation_finished.connect(_show_game_over)

"""
@brief Shows the game over screen
"""
func _show_game_over(_name: String) -> void:
	get_tree().change_scene_to_file("res://scenes/gui/game_over.tscn")


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
