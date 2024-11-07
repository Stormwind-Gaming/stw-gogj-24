extends Object

class_name CharacterFactory

static func generate_random_name() -> Dictionary:

	randomize() # Seed the random number generator
	var first_name : String = Globals.first_names[randi() % Globals.first_names.size()]
	var last_name : String = Globals.last_names[randi() % Globals.last_names.size()]

	return {"first": first_name, "last": last_name}

static func create_character() -> Character:
	var name = generate_random_name()
	var new_character = Character.new(name["first"], name["last"])
	return new_character
