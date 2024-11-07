extends Window

var character : Character

func _ready():
	# Connect the close_requested signal
	connect("close_requested", Callable(self, "_on_close_requested"))

func _on_close_requested():
	queue_free()

func set_character(name : String):
	character = GlobalRegistry.get_object('characters', name)
