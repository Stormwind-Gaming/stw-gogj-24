extends Node

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Reference to current open window
"""
var open_window: Window
var open_radial_menu: RadialMenu = null
var open_event_panels: Array[Window] = []

#|==============================|
#|      Lifecycle Methods       |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Sets up signals to listen for window events
"""
func _ready() -> void:
	EventBus.end_turn_initiated.connect(_close_all_windows)
	EventBus.open_new_window.connect(_open_new_window)
	EventBus.open_new_radial_menu.connect(_open_radial_menu)
	EventBus.close_all_windows.connect(_close_all_windows)
	EventBus.close_window.connect(_close_window)
	EventBus.close_radial_menu.connect(_close_radial_menu)
	EventBus.game_over.connect(_close_all_windows_and_event_panels)
	
	EventBus.create_new_event_panel.connect(_create_new_event_panel)
	EventBus.world_event_created.connect(_create_new_world_event_panel)

	EventBus.new_endgame_step.connect(_create_endgame_panel)

#|==============================|
#|      Methods     				   |
#|==============================|

"""
@brief Checks if any windows are open
"""
func any_windows_open() -> bool:
	return !!open_window or !!open_radial_menu or open_event_panels.size() > 0


#|==============================|
#|      Event Handlers         |
#|==============================|

"""
@brief Closes all open windows and event panels
"""
func _close_all_windows_and_event_panels() -> void:
	EventBus.close_all_windows.emit()
	for panel in open_event_panels:
		panel.queue_free()
	open_event_panels.clear()

"""
@brief Closes all open windows
"""
func _close_all_windows() -> void:
	if open_window:
		open_window.queue_free()
	if open_radial_menu:
		open_radial_menu.queue_free()
	
	open_window = null
	open_radial_menu = null

"""
@brief Closes the current window
"""
func _close_window() -> void:
	if open_window:
		open_window.queue_free()
	open_window = null

"""
@brief Closes the radial menu
"""
func _close_radial_menu() -> void:
	if open_radial_menu:
		open_radial_menu.queue_free()
	open_radial_menu = null

"""
@brief Opens a new window

@param window The window to open
@param close_all_windows Whether to close all other windows before opening
"""
func _open_new_window(window: Window, close_all_windows: bool = true) -> void:
	if open_window and open_window.name == window.name:
		# wait next tick
		await get_tree().process_frame
		EventBus.close_all_windows.emit()
		return
	if close_all_windows:
		EventBus.close_all_windows.emit()

	open_window = window
	add_child(window)
	# if there are any open event panels, move them to the front
	for panel in open_event_panels:
		move_child(panel, get_child_count() - 1)

"""
@brief Opens a radial menu

@param menu The radial menu to open
"""
func _open_radial_menu(menu: RadialMenu) -> void:
	# dont need to close all other windows for radial menu because by necessity no other windows can be open
	if open_radial_menu:
		open_radial_menu.queue_free()
	open_radial_menu = menu

"""
@brief Handles a new world event panel

@param event The world event to create a panel for
"""
func _create_new_world_event_panel(world_event: WorldEvent, config: WorldEventConfig) -> void:
	var popup = Globals.event_panel_scene.instantiate()
	popup.set_event_details_world_event(world_event, config)
	add_child(popup)
	open_event_panels.append(popup)
	popup.on_close.connect(_on_event_panel_closed)

"""
@brief Creates a new event panel

@param event_type The type of event to create a panel for
@param character The character involved in the event
@param poi The point of interest involved in the event
"""
func _create_new_event_panel(event_type: Enums.EventOutcomeType, character: Array[Character], poi: PointOfInterest) -> void:
	if event_type == Enums.EventOutcomeType.NONE or event_type >= 25:
		return
	var popup = Globals.event_panel_scene.instantiate()
	popup.set_event_details(event_type, character, poi)
	add_child(popup)
	open_event_panels.append(popup)
	popup.on_close.connect(_on_event_panel_closed)

"""
@brief Creates a new event panel

@param event_type The type of event to create a panel for
@param character The character involved in the event
@param poi The point of interest involved in the event
"""
func _create_endgame_panel(endgame_type: Enums.EventOutcomeType) -> void:
	if endgame_type < 25:
		# not an endgame event
		return
	var popup = Globals.event_panel_scene.instantiate()
	popup.set_event_endgame_event(endgame_type)
	add_child(popup)
	open_event_panels.append(popup)
	popup.on_close.connect(_on_event_panel_closed)

"""
@brief Handles the event panel being closed

@param event_panel The event panel that was closed
"""
func _on_event_panel_closed(event_panel: Window) -> void:
	open_event_panels.erase(event_panel)
	event_panel.queue_free()
