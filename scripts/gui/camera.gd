extends Node2D

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Strength of the parallax effect in the x direction
"""
@export var parallax_strength_x: float = 1000.0

"""
@brief Strength of the parallax effect in the y direction
"""
@export var parallax_strength_y: float = 1000.0

"""
@brief Maximum distance the image can move horizontally
"""
@export var max_offset_x: float = 800.0

"""
@brief Maximum distance the image can move vertically
"""
@export var max_offset_y: float = 1300.0

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Whether the camera movement is enabled
"""
var enabled: bool = true

"""
@brief The initial position of the camera
"""
var initial_position: Vector2

"""
@brief The target position for camera movement
"""
var target_position: Vector2

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

"""
@brief Called every frame to update camera position.
Handles mouse-based camera movement and district focusing.
"""
func _process(delta):
	# Check if the right mouse button is held down
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if not GameController.menus_open:
			if enabled:
				# Calculate the viewport size and mouse position
				var viewport_size = get_viewport_rect().size
				var mouse_position = get_viewport().get_mouse_position()

				# Calculate the horizontal offset based on mouse position, normalized from -1 to 1
				var horizontal_offset = (mouse_position.x / viewport_size.x) * 2 - 1
				var vertical_offset = (mouse_position.y / viewport_size.y) * 2 - 1
				
				# Calculate the new target x and y positions using parallax strengths, then clamp them
				var target_x = clamp(horizontal_offset * parallax_strength_x, -max_offset_x, max_offset_x)
				var target_y = clamp(vertical_offset * parallax_strength_y, -max_offset_y, max_offset_y)
				
				# Set the target position based on the initial position offset
				target_position.x = initial_position.x + target_x
				target_position.y = initial_position.y + target_y
				
				# Move the position to the target position
				position.x = target_position.x
				position.y = target_position.y
	elif !enabled:
		# Focus on district centerpoint when camera is disabled
		var point_to_focus_on = GameController.district_focused.get_district_centerpoint() - Vector2(800, 450)
		if self.position.distance_to(point_to_focus_on) > 1:
			position = point_to_focus_on
