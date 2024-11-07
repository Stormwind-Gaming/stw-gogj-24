extends Window

var character_profile_scene = preload("res://scenes/gui/character_profile.tscn")
@onready var character_list_container = $PanelContainer/MarginContainer/CharacterListContainer

func _ready():
	# Connect the close_requested signal
	connect("close_requested", Callable(self, "_on_close_requested"))
	
	# Fetch characters from the GlobalRegistry and populate the list
	var characters = GlobalRegistry.get_all_objects(GlobalRegistry.Registry_Category.CHARACTER)
	populate_character_list(characters)

func _on_close_requested():
	queue_free()

func populate_character_list(characters):
	# Clear existing children in the container by freeing them
	for child in character_list_container.get_children():
		child.queue_free()

	# Iterate over the dictionary to create buttons
	for name in characters.keys():
		var character_node = characters[name]
		var button = Button.new()

		# Use character_node's first_name and last_name for the button text
		button.text = character_node.first_name + " " + character_node.last_name

		# Use Callable to pass the function and arguments
		button.connect("pressed", Callable(self, "_on_character_button_pressed").bind(name, character_node))
		character_list_container.add_child(button)


func _on_character_button_pressed(name, character_node):
	# Handle character button press
	print("Selected character: ", character_node.first_name, character_node.last_name)
	
		# Instance the character list scene
	var character_profile_instance = character_profile_scene.instantiate()
	
	character_profile_instance.set_character(name)
	
	# Add the instance to the scene tree
	add_child(character_profile_instance)

	# Center the window on the screen using popup_centered()
	character_profile_instance.popup_centered()
