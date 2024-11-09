extends Object
class_name ItemFactory

static func generate_random_profile() -> Dictionary:
	randomize() # Seed the random number generator

	var item_name = Globals.items[randi() % Globals.items.size()]
	
	return {
		"item_name": item_name, 
	}

static func create_item() -> Item:
	var profile = generate_random_profile()
	var new_item = Item.new(profile)
	
	return new_item
