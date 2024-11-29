extends Window

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Label that displays the log entries
"""
@export var day_tab_container: TabContainer

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Connects signals and populates the log with current turn entries.
"""
func _ready():
	# reverse the turns so they list in descending order
	var turns = []
	for i in ReferenceGetter.game_controller().turn_number:
		turns.push_front(i + 1)
	
	# Create a new tab for each day
	for i in turns:
		var day_log = Globals.day_log_scene.instantiate()
		day_log.set_turn_logs(i)
		day_tab_container.add_child(day_log)
	
	# if turns are empty, create a label to indicate no logs
	if len(turns) == 0:
		var margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_top", 25)
		margin_container.add_theme_constant_override("margin_left", 25)
		margin_container.name = ReferenceGetter.game_controller().calendar.get_date_string(-1, false)
		# add vbox container to hold label
		var vbox = VBoxContainer.new()
		margin_container.add_child(vbox)
		var label = Label.new()
		label.text = "No logs today."
		vbox.add_child(label)
		margin_container.add_child(vbox)
		day_tab_container.add_child(margin_container)


#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the close button press.
"""
func _on_close_button_pressed() -> void:
	EventBus.close_window.emit()
