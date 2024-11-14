extends Object

class_name IntelFactory

#|==============================|
#|       Rumour Creation        |
#|==============================|
"""
@brief Creates a new Rumour based on the provided configuration.

@param config The configuration settings for the rumour
@returns A new Rumour object populated with data based on the configuration
"""
static func create_rumour(config: RumourConfig) -> Rumour:
	print('IntelFactory create_rumour')

	# Create a new instance of RumourProperties
	var rumour_properties = Rumour.RumourProperties.new()

	# Generate the type of rumour based on the provided configuration
	var rumour_type = _generate_rumour_type(config)

	# Retrieve the rumour data based on the generated type
	var rumour_data = Globals.get_rumour_data(rumour_type)

	# Assign the subject of the rumour based on the rumour data
	match rumour_data.subject:
		Enums.RumourSubject.ANY_CHARACTER:
			rumour_properties.rumour_subject_character = _get_random_character()
		Enums.RumourSubject.ANY_POI:
			rumour_properties.rumour_subject_poi = _get_random_poi()
		Enums.RumourSubject.NON_SYMPATHISER_CHARACTER:
			rumour_properties.rumour_subject_character = _get_random_non_sympathiser_character()
		Enums.RumourSubject.SYMPATHISER_CHARACTER:
			rumour_properties.rumour_subject_character = _get_random_sympathiser_character()
		Enums.RumourSubject.MIA_CHARACTER:
			rumour_properties.rumour_subject_character = _get_random_mia_character()
		Enums.RumourSubject.INCARCERATED_CHARACTER:
			rumour_properties.rumour_subject_character = _get_random_incarcerated_character()

	# Check if the rumour has a specific effect that requires duration and expiry
	if rumour_data.effect in [Enums.IntelEffect.D_ONE_E_ONE, Enums.IntelEffect.D_ONE_E_TWO, Enums.IntelEffect.D_ONE_E_THREE, Enums.IntelEffect.D_ONE_E_FOUR,
							  Enums.IntelEffect.D_TWO_E_ONE, Enums.IntelEffect.D_TWO_E_TWO, Enums.IntelEffect.D_TWO_E_THREE, Enums.IntelEffect.D_TWO_E_FOUR,
							  Enums.IntelEffect.D_THREE_E_ONE, Enums.IntelEffect.D_THREE_E_TWO, Enums.IntelEffect.D_THREE_E_THREE, Enums.IntelEffect.D_THREE_E_FOUR,
							  Enums.IntelEffect.D_FOUR_E_ONE, Enums.IntelEffect.D_FOUR_E_TWO, Enums.IntelEffect.D_FOUR_E_THREE, Enums.IntelEffect.D_FOUR_E_FOUR]:
		var duration_expiry = _get_rumour_duration_and_expiry(rumour_data.effect)
		rumour_properties.rumour_subject_duration = duration_expiry[0]
		rumour_properties.rumour_subject_expiry = duration_expiry[1]

	# Set the properties of the rumour
	rumour_properties.rumour_text = rumour_data.text
	rumour_properties.rumour_type = rumour_type
	rumour_properties.rumour_effect = rumour_data.effect

	# Initialize and return the rumour with the properties
	return Rumour.new(rumour_properties)

#|==============================|
#|     Random Character Getters  |
#|==============================|
"""
@brief Retrieves a random character from the global registry.

@returns A random Character object
"""
static func _get_random_character() -> Character:
	var characters = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	return characters[randi() % characters.size()]

"""
@brief Retrieves a random point of interest from the global registry.

@returns A random PointOfInterest object
"""
static func _get_random_poi() -> PointOfInterest:
	var pois = GlobalRegistry.get_all_objects(Enums.Registry_Category.POI)
	var pois_array = pois.values()
	return pois_array[randi() % pois_array.size()]

"""
@brief Retrieves a random non-sympathiser character from the global registry.

@returns A random Character object that is not a sympathiser
"""
static func _get_random_non_sympathiser_character() -> Character:
	var characters = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
	var non_sympathisers = characters.values().filter(func(character): return character.char_recruitment_state == Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN or character.char_recruitment_state == Enums.CharacterRecruitmentState.NON_SYMPATHISER_UNKNOWN)
	var random_non_sympathiser = non_sympathisers[randi() % non_sympathisers.size()]
	print('get_random_non_sympathiser_character', random_non_sympathiser)
	return random_non_sympathiser

"""
@brief Retrieves a random sympathiser character (currently returns null).

@returns A null value (placeholder for future implementation)
"""
static func _get_random_sympathiser_character() -> Character:
	return null

"""
@brief Retrieves a random MIA character (currently returns null).

@returns A null value (placeholder for future implementation)
"""
static func _get_random_mia_character() -> Character:
	return null

"""
@brief Retrieves a random incarcerated character (currently returns null).

@returns A null value (placeholder for future implementation)
"""
static func _get_random_incarcerated_character() -> Character:
	return null

#|==============================|
#|   Duration and Expiry Logic   |
#|==============================|
"""
@brief Gets the duration and expiry for a given intel effect.

@param effect The intel effect for which to retrieve duration and expiry
@returns An array containing duration and expiry values
"""
static func _get_rumour_duration_and_expiry(effect: Enums.IntelEffect) -> Array:
	var duration_expiry_map = {
		Enums.IntelEffect.D_ONE_E_ONE: [1, 1],
		Enums.IntelEffect.D_ONE_E_TWO: [1, 2],
		Enums.IntelEffect.D_ONE_E_THREE: [1, 3],
		Enums.IntelEffect.D_ONE_E_FOUR: [1, 4],
		Enums.IntelEffect.D_TWO_E_ONE: [2, 1],
		Enums.IntelEffect.D_TWO_E_TWO: [2, 2],
		Enums.IntelEffect.D_TWO_E_THREE: [2, 3],
		Enums.IntelEffect.D_TWO_E_FOUR: [2, 4],
		Enums.IntelEffect.D_THREE_E_ONE: [3, 1],
		Enums.IntelEffect.D_THREE_E_TWO: [3, 2],
		Enums.IntelEffect.D_THREE_E_THREE: [3, 3],
		Enums.IntelEffect.D_THREE_E_FOUR: [3, 4],
		Enums.IntelEffect.D_FOUR_E_ONE: [4, 1],
		Enums.IntelEffect.D_FOUR_E_TWO: [4, 2],
		Enums.IntelEffect.D_FOUR_E_THREE: [4, 3],
		Enums.IntelEffect.D_FOUR_E_FOUR: [4, 4],
	}
	return duration_expiry_map[effect]

#|==============================|
#|     Rumour Type Generation    |
#|==============================|
"""
@brief Generates a rumour type based on the provided configuration.

@param config The configuration settings for rumour type generation
@returns The generated RumourType based on random chance
"""
static func _generate_rumour_type(config: RumourConfig) -> Enums.RumourType:
	var random_value = randi() % 100

	if random_value < config.mission_chance:
		return Enums.RumourType.MISSION
	elif random_value < config.mission_chance + config.location_chance:
		return Enums.RumourType.LOCATION
	else:
		return Enums.RumourType.TIME

"""
@brief Combines multiple rumours into a plan.

@param rumours Array of rumours to combine
@returns A new Plan object
"""
static func combine_rumours(rumours: Array[Rumour]) -> Plan:
	print('IntelFactory combine_rumours', rumours)
	return Plan.new()
