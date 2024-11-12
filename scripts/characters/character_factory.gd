extends Object
class_name CharacterFactory

static func generate_random_profile() -> Dictionary:
	randomize() # Seed the random number generator
	
	# Determine nationality and gender
	var nationality = _nationality()
	var gender = randi() % Enums.CharacterGender.size()
	
	# Generate a random name
	var name_arr = _generate_name(nationality, gender)
	
	# Determine image path based on nationality and gender
	var nationality_str = _get_nationality_string(nationality)
	var gender_str = _get_gender_string(gender)
	var image_directory = "res://assets/profile_pictures/%s/%s/" % [nationality_str, gender_str]

	# Select a random image from the directory
	var selected_image = _get_random_image_from_path(image_directory)
	
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

	# 50% chance of known
	if randi() % 2 == 0:
		new_character.known = true
	
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
	
	if rand < 40:
			return Enums.CharacterNationality.BELGIAN  # 40% chance
	elif rand < 70:
		return Enums.CharacterNationality.GERMAN   # 30% chance (40-69)
	elif rand < 90:
		return Enums.CharacterNationality.FRENCH   # 20% chance (70-89)
	else:
		return Enums.CharacterNationality.BRITISH  # 10% chance (90-99)

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
