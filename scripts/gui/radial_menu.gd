extends Control
class_name RadialMenu

#|==============================|
#|         Constants           |
#|==============================|
"""
@brief Size of the sprite icons in the menu
"""
const SPRITE_SIZE = Vector2(64, 64)

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Color of the menu background
"""
@export var background_color: Color

"""
@brief Color of the menu lines
"""
@export var line_color: Color

"""
@brief Color of the highlighted option
"""
@export var highlight_color: Color

"""
@brief Radius of the outer circle
"""
@export var outer_radius: int = 128

"""
@brief Radius of the inner circle
"""
@export var inner_radius: int = 32

"""
@brief Width of the menu lines
"""
@export var line_width: int = 4

"""
@brief Area that will close the menu when clicked
"""
@export var click_away_area: Area2D

"""
@brief Window radial popup
"""
@export var radial_popup: Window
#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Array of available options in the menu
"""
var options: Array[RadialOption]

"""
@brief Currently selected cell index
"""
var selected_cell = 0

"""
@brief Point of interest to assign actions to
"""
var poi: PointOfInterest

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Initializes the radial menu with given options.

@param options_attr Array of action types to include in the menu
"""
func _init(options_attr: Array[Enums.ActionType] = []) -> void:
	options = []
	options_attr.append(Enums.ActionType.NONE)
	options_attr.append(Enums.ActionType.INFO)
	for option in options_attr:
		options.append(RadialOption.new(option))

"""
@brief Called every frame to update menu state.
Updates selected cell based on mouse position.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	if mouse_radius > outer_radius:
		radial_popup.visible = false
		selected_cell = -1
	elif mouse_radius < inner_radius:
		radial_popup.visible = false
		selected_cell = 0
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selected_cell = ceil((mouse_rads / TAU) * (len(options) - 1))
		
		# popup at mouse position
		radial_popup.visible = true
		$Popup/PanelContainer/MarginContainer/VBoxContainer/Label.text = options[selected_cell].radial_option_name
		radial_popup.set_position(get_viewport().get_mouse_position() + Vector2(10, 10))

	queue_redraw()

"""
@brief Called to draw the radial menu.
Handles all custom drawing operations for the menu.
"""
func _draw() -> void:
	var offset = SPRITE_SIZE / -2
	
	# draw main circle
	draw_circle(Vector2.ZERO, outer_radius, background_color)
	
	if selected_cell == 0:
		draw_circle(Vector2.ZERO, inner_radius - (line_width / 2), highlight_color)
	
	# draw center cell
	draw_texture_rect_region(
		options[0].atlas,
		Rect2(offset, SPRITE_SIZE),
		options[0].region
	)
	
	for i in range(1, len(options)):
		var start_rads = (TAU * (i - 1)) / (len(options) - 1)
		var end_rads = (TAU * (i)) / (len(options) - 1)
		var mid_rads = (start_rads + end_rads) / 2.0 * -1
		var mid_radius = (inner_radius + outer_radius) / 2
		
		if selected_cell == i:
			var points_per_arc = 32
			var points_inner = PackedVector2Array()
			var points_outer = PackedVector2Array()
			
			for j in range(points_per_arc + 1):
				var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
				points_inner.append(inner_radius * Vector2.from_angle(TAU - angle))
				points_outer.append(outer_radius * Vector2.from_angle(TAU - angle))
			
			if len(options) >= 3:
				points_outer.reverse()
			draw_polygon(
				points_inner + points_outer,
				PackedColorArray([highlight_color])
			)
		
		var draw_pos = mid_radius * Vector2.from_angle(mid_rads) + offset
		draw_texture_rect_region(
			options[i].atlas,
			Rect2(draw_pos, SPRITE_SIZE),
			options[i].region
		)
	
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, line_color, line_width, true)
	draw_arc(Vector2.ZERO, outer_radius, 0, TAU, 128, line_color, line_width, true)
	
	# draw separator lines
	for i in range(len(options) - 1):
		var rads = TAU * i / (len(options) - 1)
		var point = Vector2.from_angle(rads)
		draw_line(
			point * inner_radius,
			point * outer_radius,
			line_color,
			line_width,
			true
		)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles input events for the menu area.
Processes mouse clicks and emits selection signals.

@param viewport The viewport that received the event
@param event The input event
@param shape_idx The shape index that was clicked
"""
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			EventBus.close_radial_menu.emit()
			EventBus.selected_radial_option.emit(options[selected_cell].action_type, poi)

func _on_close_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			EventBus.close_radial_menu.emit()

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Adds optional actions to the menu.

@param options_attr Array of action types to add
"""
func set_optional_actions(poi: PointOfInterest, options_attr: Array[Enums.ActionType] = []) -> void:
	for option in options_attr:
		options.append(RadialOption.new(option))
	
	self.poi = poi
