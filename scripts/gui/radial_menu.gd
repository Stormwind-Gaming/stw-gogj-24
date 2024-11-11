extends Control
class_name RadialMenu

const SPRITE_SIZE = Vector2(64,64)

@export var background_color: Color
@export var line_color: Color
@export var highlight_color: Color

@export var outer_radius: int = 128
@export var inner_radius: int = 32
@export var line_width: int = 4

var options: Array[RadialOption]

var selected_cell = 0

signal selected_radial_option(option: Enums.ActionType)

func _init(options_attr: Array[Enums.ActionType] = []) -> void:
	options = []
	options_attr.append(Enums.ActionType.NONE)
	options_attr.append(Enums.ActionType.INFO)
	options_attr.append(Enums.ActionType.ESPIONAGE)
	options_attr.append(Enums.ActionType.PROPAGANDA)
	options_attr.append(Enums.ActionType.SURVEILLANCE)
	options_attr.append(Enums.ActionType.PLAN)
	for option in options_attr:
		options.append(RadialOption.new(option))

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
		var start_rads = (TAU * (i-1)) / (len(options) - 1)
		var end_rads = (TAU * (i)) / (len(options) - 1)
		var mid_rads = (start_rads + end_rads) / 2.0 * -1
		var mid_radius = (inner_radius + outer_radius) / 2
		
		if selected_cell == i:
			var points_per_arc = 32
			var points_inner = PackedVector2Array()
			var points_outer = PackedVector2Array()
			
			for j in range(points_per_arc + 1):
				var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
				points_inner.append(inner_radius * Vector2.from_angle(TAU-angle))
				points_outer.append(outer_radius * Vector2.from_angle(TAU-angle))
			
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
	for i in range(len(options)-1):
		var rads = TAU * i / (len(options)-1)
		var point = Vector2.from_angle(rads)
		draw_line(
			point*inner_radius,
			point*outer_radius,
			line_color,
			line_width,
			true
		)

func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	if mouse_radius > outer_radius:
		selected_cell = -1
	elif mouse_radius < inner_radius:
		selected_cell = 0
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selected_cell = ceil((mouse_rads / TAU) * (len(options) -1))

	queue_redraw()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			emit_signal("selected_radial_option", options[selected_cell].action_type)
