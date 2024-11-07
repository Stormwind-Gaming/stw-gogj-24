extends Node2D

@export var parallax_strength_x: float = -400.0  # Strength of the parallax effect in the x direction
@export var parallax_strength_y: float = -400.0  # Strength of the parallax effect in the y direction
@export var max_offset_x: float = 300.0  # Maximum distance the image can move horizontally
@export var max_offset_y: float = 300.0  # Maximum distance the image can move vertically
@export var lerp_speed: float = 3.0  # Smoothing speed for the lerp

var enabled: bool = true

# Store the initial position as an offset
var initial_position: Vector2
var target_position: Vector2

func _ready():
	# Set the initial position as the starting offset
	initial_position = position
	target_position = position

func _process(delta):
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
		
		# Smoothly move the position towards the target position using lerp
		position.x = lerp(position.x, target_position.x, lerp_speed * delta)
		position.y = lerp(position.y, target_position.y, lerp_speed * delta)
