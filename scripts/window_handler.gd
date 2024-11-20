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
	
	EventBus.log_created.connect(_create_new_event_panel)

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
	print("Closing all windows and event panels")
	_close_all_windows()
	for panel in open_event_panels:
		panel.queue_free()
	open_event_panels.clear()

"""
@brief Closes all open windows
"""
func _close_all_windows() -> void:
	print("Closing all windows")
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
		_close_all_windows()
		return
	if close_all_windows:
		_close_all_windows()

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
@brief Creates a new event panel

@param log The log to display
"""
func _create_new_event_panel(log_attr: TurnLog) -> void:
	if log_attr.event_type == Enums.EventOutcomeType.NONE:
		return
	print("Creating new event panel")
	if log_attr.log_type == Enums.LogType.CONSEQUENCE:
		print("Creating new event panel", log_attr.log_message)
	var popup = Globals.event_panel_scene.instantiate()
	popup.set_event_details(log_attr)
	add_child(popup)
	open_event_panels.append(popup)
	popup.on_close.connect(_on_event_panel_closed)
	pass

"""
@brief Handles the event panel being closed

@param event_panel The event panel that was closed
"""
func _on_event_panel_closed(event_panel: Window) -> void:
	open_event_panels.erase(event_panel)
	event_panel.queue_free()
	pass
