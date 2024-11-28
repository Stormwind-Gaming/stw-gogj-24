extends ProgressBar

var breakpoints = [
	float(Constants.GLOBAL_HEAT_BREAKPOINT_MEDIUM) / Constants.HEAT_ENDGAME_THRESHOLD,
	float(Constants.GLOBAL_HEAT_BREAKPOINT_HIGH) / Constants.HEAT_ENDGAME_THRESHOLD
] 

func _ready():
	pass

func _draw():
	# Get the width and height of the ProgressBar
	var bar_width = size.x
	var bar_height = size.y
	
	# Draw the markers
	for point in breakpoints:
		var x_pos = point * bar_width
		var dash_length = 4
		var gap_length = 4
		var current_y = 0
		while current_y < bar_height:
			var end_y = min(current_y + dash_length, bar_height)
			draw_line(Vector2(x_pos, current_y), Vector2(x_pos, end_y), get_theme_color("fill_color"), 2)
			current_y = end_y + gap_length
