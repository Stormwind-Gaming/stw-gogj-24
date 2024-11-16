extends Object
class_name CharacterFactory

static func generate_random_profile() -> Dictionary:
	randomize() # Seed the random number generator
	
	# Determine nationality and gender
	var nationality = _nationality()
	var gender = randi() % Enums.CharacterGender.size()
	
	# Generate a random name
	var name_arr = _generate_name(nationality, gender)
	
	# New code for selecting random image from preloaded images
	var selected_image = Globals.get_next_profile_image(nationality, gender)

	return {
		"first_name": name_arr[0], 
		"last_name": name_arr[1],
		"nationality": nationality,
		"gender": gender,
		"image_path": selected_image,
		"national_id_number": randi() % 10000000
	}

static func _generate_name(nationality: Enums.CharacterNationality, gender: Enums.CharacterGender) -> Array[String]:
	# Select the correct lists for naming based on nationality and gender
	var last_name_bag: Array
	var first_name_bag: Array

	last_name_bag = Globals.get_all_last_names(nationality)
	first_name_bag = Globals.get_all_first_names(gender, nationality)
	
	# Randomize name
	var last_name: String = last_name_bag[randi() % last_name_bag.size()].last_name
	var first_name: String = first_name_bag[randi() % first_name_bag.size()].first_name

	return [first_name, last_name]

static func create_character() -> Character:
	var profile = generate_random_profile()
	var new_character = Character.new(profile)
	
	return new_character

# Helper function to convert nationality enum to string
static func _get_nationality_string(nationality: Enums.CharacterNationality) -> String:
	match nationality:
		Enums.CharacterNationality.BELGIAN:
			return "belgian"
		Enums.CharacterNationality.GERMAN:
			return "german"
		Enums.CharacterNationality.BRITISH:
			return "british"
		Enums.CharacterNationality.FRENCH:
			return "french"
		_:
			return "default"
			
# Helper function to convert gender enum to string
static func _get_gender_string(gender: int) -> String:
	match gender:
		Enums.CharacterGender.MALE:
			return "male"
		Enums.CharacterGender.FEMALE:
			return "female"
		_:
			return "default"

static func _nationality() -> Enums.CharacterNationality:
	var rand = randi() % 100  # Generate a random number between 0 and 99
	
	if rand < 50:
			return Enums.CharacterNationality.BELGIAN  # 50% chance
	elif rand < 80:
		return Enums.CharacterNationality.GERMAN   # 30% chance (50-79)
	elif rand < 95:
		return Enums.CharacterNationality.FRENCH   # 15% chance (80-94)
	else:
		return Enums.CharacterNationality.BRITISH  # 5% chance (95-99)

# Helper function to get a random image from a specified path
static func _get_random_image_from_path(path: String) -> String:
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Cannot open directory: " + path)
		return ""
	
	# Initialize directory listing
	dir.list_dir_begin() # Skip hidden files and don't follow symlinks
	
	var files = []
	var file = dir.get_next()
	while file != "":
		if not dir.current_is_dir() and _is_image_file(file):
			files.append(file)
		file = dir.get_next()
	
	dir.list_dir_end() # Clean up after listing
	
	if files.size() == 0:
		push_error("No images found in directory: " + path)
		return ""
	
	var random_index = randi() % files.size()
	return path + files[random_index]


# Helper function to check if a file is an image
static func _is_image_file(file: String) -> bool:
	var lower_file = file.to_lower()
	return lower_file.ends_with(".png") or lower_file.ends_with(".jpg") or lower_file.ends_with(".jpeg") or lower_file.ends_with(".bmp") or lower_file.ends_with(".tga")
