extends Window

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief The character whose profile is being displayed
"""
var character: Character

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Connects signals and initializes the profile display.
"""
func _ready():
	# Connect the close_requested signal
	connect("close_requested", Callable(self, "_on_close_requested"))

	var stats = character.get_stats()
	
	# Set up the character's profile information
	$MarginContainer/VBoxContainer/TextureRect.texture = load(character.picture)
	$MarginContainer/VBoxContainer/Label.text = "Name: " + character.first_name + " " + character.last_name + "\n" + \
											   "Charm: " + str(stats.charm) + "\n" + \
											   "Subtlety: " + str(stats.subtlety) + "\n" + \
											   "Smarts: " + str(stats.smarts)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the window close request.
Removes this window from the scene tree.
"""
func _on_close_requested():
	queue_free()

#|==============================|
#|      Setters & Getters      |
#|==============================|
"""
@brief Sets the character whose profile will be displayed.

@param name The unique identifier of the character to display
"""
func set_character(id: String):
	character = GlobalRegistry.get_object(Enums.Registry_Category.CHARACTER, id)
