extends Node

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Reference to current open window
"""
var open_windows: Array[Window] = []
var open_radial_menu: RadialMenu = null

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
	pass

#|==============================|
#|      Event Handlers         |
#|==============================|

"""
@brief Closes all open windows
"""
func _close_all_windows(emit: bool = true) -> void:
	print("Closing all windows")
	if open_windows:
		for window in open_windows:
			window.queue_free()
	if open_radial_menu:
		open_radial_menu.queue_free()
	
	open_windows = []
	open_radial_menu = null


"""
@brief Opens a new window

@param window The window to open
@param close_all_windows Whether to close all other windows before opening
"""
func _open_new_window(window: Window, close_all_windows: bool = true) -> void:
	if close_all_windows:
		_close_all_windows(false)

	open_windows.append(window)
	add_child(window)

"""
@brief Opens a radial menu

@param menu The radial menu to open
"""
func _open_radial_menu(menu: RadialMenu) -> void:
	# dont need to close all other windows for radial menu because by necessity no other windows can be open
	if open_radial_menu:
		open_radial_menu.queue_free()
	open_radial_menu = menu
