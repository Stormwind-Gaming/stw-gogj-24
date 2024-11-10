extends Window

var character : Character

func _ready():
	# Connect the close_requested signal
	connect("close_requested", Callable(self, "_on_close_requested"))

	var stats = character.get_stats()
	
	$MarginContainer/VBoxContainer/TextureRect.texture = load(character.picture)
	$MarginContainer/VBoxContainer/Label.text = "Name: " + character.first_name + " " + character.last_name + "\n" + "Charm: " + str(stats.charm) + "\n" + "Subtlety: " + str(stats.subtlety) + "\n" + "Smarts: " + str(stats.smarts)

func _on_close_requested():
	queue_free()

func set_character(name : String):
	character = GlobalRegistry.get_object(Enums.Registry_Category.CHARACTER, name)
