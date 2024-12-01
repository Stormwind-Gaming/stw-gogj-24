extends Camera2D

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Strength of the parallax effect in the x direction
"""
@export var parallax_strength_x: float = 0.5

"""
@brief Strength of the parallax effect in the y direction
"""
@export var parallax_strength_y: float = 0.5

"""
@brief Sensitivity of the camera movement
"""
@export var sensitivity: float = 3.5

"""
@brief Maximum distance the image can move horizontally
"""
@export var max_offset_x: float = 800.0

"""
@brief Maximum distance the image can move vertically
"""
@export var max_offset_y: float = 1300.0

"""
@brief Movement speed for keyboard controls (WASD)
"""
@export var keyboard_speed: float = 1500.0

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Whether the camera movement is enabled
"""
var camera_enabled: bool = true

"""
@brief The initial position of the camera
"""
var initial_position: Vector2

"""
@brief The target position for camera movement
"""
var target_position: Vector2

"""
@brief The initial zoom level
"""
var initial_zoom: Vector2 = Vector2(1, 1)

"""
@brief The target zoom level
"""
var target_zoom: Vector2 = Vector2(1, 1)

"""
@brief Whether to draw debug information
"""
var debug_draw: bool = false

"""
@brief The current zoom level
"""
var current_zoom: Vector2 = Vector2(1, 1)

"""
@brief The previous mouse position
"""
var previous_mouse_position: Vector2 = Vector2.ZERO

"""
@brief Whether the mouse is currently dragging
"""
var is_dragging: bool = false
#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Sets up initial camera position.
"""
func _ready():
	initial_position = position
	target_position = position
	
	# Store initial zoom from the camera and set current zoom
	initial_zoom = self.zoom
	current_zoom = initial_zoom
	target_zoom = initial_zoom

"""
@brief Called every frame to update camera position.
Handles mouse-based camera movement and district focusing.
"""
func _process(delta):
	queue_redraw() # Ensure continuous redrawing
	
	# Handle keyboard movement (WASD)
	if camera_enabled:
		var movement = Vector2.ZERO
		if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
			movement.y -= 1
		if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
			movement.y += 1
		if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
			movement.x -= 1
		if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
			movement.x += 1
			
		# Apply movement if any keys are pressed
		if movement != Vector2.ZERO:
			movement = movement.normalized() * keyboard_speed * delta
			position += movement
			
			# Clamp the position within the maximum offsets
			position.x = clamp(position.x, initial_position.x - max_offset_x, initial_position.x + max_offset_x)
			position.y = clamp(position.y, initial_position.y - max_offset_y, initial_position.y + max_offset_y)
	
	# Check if the right mouse button is held down
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and not mouse_off_screen):
		if WindowHandler.any_windows_open():
			EventBus.close_all_windows.emit()
		if camera_enabled:
			if not is_dragging:
				is_dragging = true
				previous_mouse_position = get_viewport().get_mouse_position()
			# Get the current mouse position
			var mouse_position = get_viewport().get_mouse_position()

			# Calculate the delta since the last frame
			var mouse_delta = mouse_position - previous_mouse_position

			# Apply the movement to the camera
			position += mouse_delta * sensitivity

			# Clamp the position within the maximum offsets
			position.x = clamp(position.x, initial_position.x - max_offset_x, initial_position.x + max_offset_x)
			position.y = clamp(position.y, initial_position.y - max_offset_y, initial_position.y + max_offset_y)

			# Update the previous_mouse_position for consistent movement
			previous_mouse_position = mouse_position
	elif !camera_enabled:
		# Calculate zoom to fit district
		var district_size = ReferenceGetter.game_controller().district_focused.get_district_size()
		var viewport_size = get_viewport_rect().size
		
		# Calculate zoom with more padding for small districts
		var zoom_x = viewport_size.x / district_size.x
		var zoom_y = viewport_size.y / district_size.y
		var base_zoom = min(zoom_x, zoom_y)
		
		# Add more padding for smaller districts
		var padding_multiplier = 0.8 # Default padding
		if base_zoom > 2.0: # If we're zooming in a lot (small district)
			padding_multiplier = 0.6 # Use more padding (less zoom)
		
		# Clamp the zoom to prevent extreme values
		var target_zoom_value = min(base_zoom * padding_multiplier, 2.0) # Maximum zoom of 2.0
		target_zoom = Vector2(target_zoom_value, target_zoom_value)
		
		# Focus on district centerpoint when camera is disabled
		var point_to_focus_on = ReferenceGetter.game_controller().district_focused.get_district_centerpoint()
		
		# Subtract half the viewport size (accounting for zoom), but only apply half the offset
		var viewport_offset = viewport_size / (2 * target_zoom_value)
		point_to_focus_on -= viewport_offset / 2
		
		# Lerp position directly to the district center
		position = position.lerp(point_to_focus_on, 0.05)
		
		# Lerp the zoom
		current_zoom = current_zoom.lerp(target_zoom, 0.05)
		self.zoom = current_zoom
	else:
		is_dragging = false
	

	# if not at initial zoom, lerp back to it
	if current_zoom != initial_zoom:
		current_zoom = current_zoom.lerp(initial_zoom, 0.05)
		self.zoom = current_zoom


var mouse_off_screen = false
"""
@brief Called when the mouse enters or leaves the viewport
"""
func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		mouse_off_screen = false
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		mouse_off_screen = true
