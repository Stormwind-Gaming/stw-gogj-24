extends NodeWithCleanup
class_name Map

#|==============================|
#|     Game Logic Singletons    |
#|==============================|
"""
@brief Reference to the game controller singleton
"""
var game_controller: GameController

"""
@brief Reference to the global registry singleton
"""
var global_registry: GlobalRegistry

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

func _init() -> void:
	# set up the game controller and global registry
	game_controller = GameController.new()
	global_registry = GlobalRegistry.new()
	LogDuck.d("Map: Setting up game controller and global registry")

"""
@brief Called when the node enters the scene tree.
Initializes the map, districts, and starting agents.
"""
func _ready() -> void:
	LogDuck.d("Map: Initializing map scene")
	randomize()

	# check if the sound is enabled
	if Globals.sound_enabled:
		$Game/WindEffect.play()
		$Game/StreetEffect.play()

	$Game/AnimationPlayer.play("fade_in")
	#TODO: # randomise cloud noise (currently disabled due to jumping when scene loads)
	$Game/Clouds.material.get_shader_parameter("noiseTexture").noise.seed = randi()
	EventBus.end_turn_initiated.connect(_clear_focus)
	EventBus.open_new_window.connect(_disable_interaction)
	EventBus.close_all_windows.connect(_enable_interaction)
	EventBus.close_window.connect(_enable_interaction)
	EventBus.game_over.connect(_game_over)

	LogDuck.d("Map: Setting up event bus connections")

	LogDuck.d("Map: Initializing districts")
	for district in ReferenceGetter.global_registry().districts.get_all_items():
		_set_district_details(district)

	LogDuck.d("Map: Generating initial population and agents")
	_generate_population()
	_setup_agents()

	# Create initial rumours
	LogDuck.d("Map: Creating initial rumors")
	IntelFactory.create_rumour(RumourConfig.new(100, 0, 0))
	IntelFactory.create_rumour(RumourConfig.new(0, 100, 0))
	IntelFactory.create_rumour(RumourConfig.new(0, 0, 100))

"""
@brief Called every frame to handle input.
Checks for middle/right click to clear district focus.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	if ReferenceGetter.game_controller().district_focused != null:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			EventBus.close_all_windows.emit()
			_clear_focus()
	if Input.is_action_just_pressed("ui_cancel"):
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
	LogDuck.d("Map: Clearing district focus")
	EventBus.district_unfocused.emit(ReferenceGetter.game_controller().district_focused)
	ReferenceGetter.game_controller().set_district_focused(null)
	$Game/Camera2D.camera_enabled = true

	## Enabling clouds and sound
	# Access the material and shader
	var material = $Game/Clouds.material
	# Create a tween to animate the shader's alpha_multiplier property
	var clouds_tween = create_tween()
	clouds_tween.tween_property(material, "shader_parameter/alpha_multiplier", 0.7, 1.0).set_ease(Tween.EASE_IN)

	var wind_tween = create_tween()
	wind_tween.tween_property($Game/WindEffect, "volume_db", 0, 1.0).set_ease(Tween.EASE_IN)

	var street_tween = create_tween()
	street_tween.tween_property($Game/StreetEffect, "volume_db", -80, 1.0).set_ease(Tween.EASE_OUT)

"""
@brief Sets up a district with random name and description

@param district The district to initialize
"""
func _set_district_details(district: District) -> void:
	var district_name = Globals.district_names[randi() % Globals.district_names.size()]
	Globals.district_names.erase(Globals.district_names.find(district_name))
	LogDuck.d("Map: Setting up district with name: %s" % district_name)
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
	if ReferenceGetter.game_controller().district_focused == null:
		district.set_highlight_color()

"""
@brief Handles district unhover events
@param district The district being unhovered
"""
func _on_district_unhovered(district: District) -> void:
	if ReferenceGetter.game_controller().district_focused == null:
		district.remove_highlight_color()

"""
@brief Handles district click events
@param district The district being clicked
"""
func _on_district_clicked(district: District) -> void:
	LogDuck.d("Map: District clicked: %s" % district.name)
	if ReferenceGetter.game_controller().district_focused == district:
		LogDuck.d("Map: District already focused, ignoring click")
		return

	for d in ReferenceGetter.global_registry().districts.get_all_items():
		d.remove_highlight_color()
		d.unset_focus()
	
	district.set_focus()
	$Game/Camera2D.camera_enabled = false
	ReferenceGetter.game_controller().set_district_focused(district)

	## Disabling clouds and sound
	# Access the material and shader
	var material = $Game/Clouds.material
	# Create a tween to animate the shader's alpha_multiplier property
	var clouds_tween = create_tween()
	clouds_tween.tween_property(material, "shader_parameter/alpha_multiplier", 0.0, 1.0).set_ease(Tween.EASE_IN)

	var wind_tween = create_tween()
	wind_tween.tween_property($Game/WindEffect, "volume_db", -80, 1.0).set_ease(Tween.EASE_OUT)

	var street_tween = create_tween()
	street_tween.tween_property($Game/StreetEffect, "volume_db", -10, 1.0).set_ease(Tween.EASE_IN)


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
	LogDuck.d("Map: Disabling district interactions")
	for district in ReferenceGetter.global_registry().districts.get_all_items():
		district.set_disabled()

"""
@brief Enables interaction with the map
"""
func _enable_interaction() -> void:
	LogDuck.d("Map: Enabling district interactions")
	for district in ReferenceGetter.global_registry().districts.get_all_items():
		district.set_enabled()

"""
@brief Handles game over event
"""
func _game_over() -> void:
	LogDuck.d("Map: Game over triggered")
	EventBus.close_all_windows_and_event_panels.emit()
	_disable_interaction(0)
	$Game/AnimationPlayer.play("fade_out")
	$Game/AnimationPlayer.animation_finished.connect(_show_game_over)

"""
@brief Shows the game over screen
"""
func _show_game_over(_name: String) -> void:
	# hide Game and UI
	$Game.hide()
	$UI/Footer.hide()
	$UI/Header.hide()
	# disable both audio effects
	$Game/WindEffect.stop()
	$Game/StreetEffect.stop()
	# show game over screen
	var game_over_scene = Globals.game_over_scene.instantiate()
	# add the scene to the UI
	$UI.add_child(game_over_scene)


"""
@brief Resets the map scene and children
"""
func reset() -> void:
	LogDuck.d("Map: Resetting map scene")
	
	# reset 
	game_controller.reset()
	global_registry.reset()

	# disconnect signals
	if EventBus.end_turn_initiated.is_connected(_clear_focus):
		EventBus.end_turn_initiated.disconnect(_clear_focus)
	if EventBus.open_new_window.is_connected(_disable_interaction):
		EventBus.open_new_window.disconnect(_disable_interaction)
	if EventBus.close_all_windows.is_connected(_enable_interaction):
		EventBus.close_all_windows.disconnect(_enable_interaction)
	if EventBus.close_window.is_connected(_enable_interaction):
		EventBus.close_window.disconnect(_enable_interaction)
	if EventBus.game_over.is_connected(_game_over):
		EventBus.game_over.disconnect(_game_over)



#|==============================|
#|      Character Setup        |
#|==============================|
"""
@brief Generates initial population including some special cases
"""
func _generate_population() -> void:
	LogDuck.d("Map: Generating initial population")
	var population = ReferenceGetter.global_registry().characters.get_all_items()
	# set one character to deceased and one to MIA
	var deceased = population[randi() % population.size()]
	deceased.char_state = Enums.CharacterState.DECEASED
	LogDuck.d("Map: Set character %s as deceased" % deceased.name)
	population.erase(deceased)
	var mia = population[randi() % population.size()]
	mia.char_state = Enums.CharacterState.MIA
	mia.char_sympathy = randi_range(80, 100)
	LogDuck.d("Map: Set character %s as MIA with sympathy %d" % [mia.name, mia.char_sympathy])

"""
@brief Sets up initial agent characters with high sympathy
"""
func _setup_agents() -> void:
	LogDuck.d("Map: Setting up initial agents")
	var population = ReferenceGetter.global_registry().characters.get_all_items().filter(func(x): return x.char_state == Enums.CharacterState.AVAILABLE)
	
	# Pick three random characters to be initial agents
	var agent1 = population[randi() % population.size()]
	population.erase(agent1)
	var agent2 = population[randi() % population.size()]
	population.erase(agent2)
	var agent3 = population[randi() % population.size()]
	
	LogDuck.d("Map: Initializing agents: %s, %s, %s" % [agent1.name, agent2.name, agent3.name])
	agent1.char_sympathy = randi_range(80, 100)
	agent1.char_recruitment_state = Enums.CharacterRecruitmentState.SYMPATHISER_RECRUITED
	agent2.char_sympathy = randi_range(80, 100)
	agent2.char_recruitment_state = Enums.CharacterRecruitmentState.SYMPATHISER_RECRUITED
	agent3.char_sympathy = randi_range(80, 100)
	agent3.char_recruitment_state = Enums.CharacterRecruitmentState.SYMPATHISER_RECRUITED

	agent1.char_state = Enums.CharacterState.INJURED
