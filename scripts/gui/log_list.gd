extends Window

@onready var label = $PanelContainer/MarginContainer/LogListContainer/Label

func _ready():
	# Connect the close_requested signal
	connect("close_requested", Callable(self, "_on_close_requested"))
	
	for line in GameController.get_turn_log(GameController.turn_number):
		label.text += line + "\n"

func _on_close_requested():
	queue_free()
