extends Object
class_name CharacterFactory

static func generate_random_profile() -> Dictionary:
	randomize() # Seed the random number generator
	
	# Determine nationality and gender
	var nationality = randi() % Enums.CharacterNationality.size()
	var gender = randi() % Enums.CharacterGender.size()
	
	# Select the correct lists for naming based on nationality and gender
	var last_name_bag: Array
	var first_name_bag: Array
	
	match nationality:
		Enums.CharacterNationality.BELGIAN:
			match gender:
				Enums.CharacterGender.MALE:
					last_name_bag = Globals.belgian_last_names
					first_name_bag = Globals.belgian_male_first_names
				Enums.CharacterGender.FEMALE:
					last_name_bag = Globals.belgian_last_names
					first_name_bag = Globals.belgian_female_first_names
				_:
					last_name_bag = Globals.default_last_names
					first_name_bag = Globals.default_first_names
		Enums.CharacterNationality.GERMAN:
			match gender:
				Enums.CharacterGender.MALE:
					last_name_bag = Globals.german_last_names
					first_name_bag = Globals.german_male_first_names
				Enums.CharacterGender.FEMALE:
					last_name_bag = Globals.german_last_names
					first_name_bag = Globals.german_female_first_names
				_:
					last_name_bag = Globals.default_last_names
					first_name_bag = Globals.default_first_names
		_:
			last_name_bag = Globals.default_last_names
			first_name_bag = Globals.default_first_names
	
	# Randomize name
	var last_name: String = last_name_bag[randi() % last_name_bag.size()]
	var first_name: String = first_name_bag[randi() % first_name_bag.size()]
	
	# Determine image path based on nationality and gender
	var nationality_str = _get_nationality_string(nationality)
	var gender_str = _get_gender_string(gender)
	var image_directory = "res://assets/profile_pictures/%s/%s/" % [nationality_str, gender_str]

	# Select a random image from the directory
	var selected_image = _get_random_image_from_path(image_directory)
	
	print('Chose ' + selected_image)
	
	return {
		"first_name": first_name, 
		"last_name": last_name, 
		"nationality": nationality,
		"gender": gender,
		"image_path": selected_image
	}

static func create_character() -> Character:
	var profile = generate_random_profile()
	var new_character = Character.new(profile)
	
	return new_character

# Helper function to convert nationality enum to string
static func _get_nationality_string(nationality: int) -> String:
	match nationality:
		Enums.CharacterNationality.BELGIAN:
			return "belgian"
		Enums.CharacterNationality.GERMAN:
			return "german"
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
