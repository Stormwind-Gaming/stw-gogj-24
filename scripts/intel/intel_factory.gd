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
	return GlobalRegistry.pois.get_random_item()

"""
@brief Retrieves a random non-sympathiser character from the global registry.

@returns A random Character object that is not a sympathiser
"""
static func _get_random_non_sympathiser_character() -> Character:
	#TODO: this actually needs to be a random character from either LIST_NON_SYMPATHISER_KNOWN or LIST_NON_SYMPATHISER_UNKNOWN
	return GlobalRegistry.characters.get_random_item_from_list(GlobalRegistry.LIST_NON_SYMPATHISER_KNOWN)

"""
@brief Retrieves a random sympathiser character (currently returns null).

@returns A null value (placeholder for future implementation)
"""
static func _get_random_sympathiser_character() -> Character:
	#TODO: this actually needs to be a random character from either LIST_SYMPATHISER_RECRUITED or LIST_SYMPATHISER_NOT_RECRUITED
	return GlobalRegistry.characters.get_random_item_from_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED)

"""
@brief Retrieves a random MIA character (currently returns null).

@returns A null value (placeholder for future implementation)
"""
static func _get_random_mia_character() -> Character:
	return GlobalRegistry.characters.get_random_item_from_list(GlobalRegistry.LIST_MIA)

"""
@brief Retrieves a random incarcerated character (currently returns null).

@returns A null value (placeholder for future implementation)
"""
static func _get_random_incarcerated_character() -> Character:
	return GlobalRegistry.characters.get_random_item_from_list(GlobalRegistry.LIST_INCARCERATED)

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
static func formulate_plan(mission_rumour: Rumour, location_rumour: Rumour, time_rumour: Rumour) -> Plan:
	print('IntelFactory formulate_plan')

	var plan_properties = Plan.PlanProperties.new()

	plan_properties.plan_name = "Operation " + str(randi() % 1000)
	plan_properties.plan_text = mission_rumour.rumour_text + "\n\n" + location_rumour.rumour_text + "\n\n" + time_rumour.rumour_text
	plan_properties.plan_duration = time_rumour.rumour_subject_duration
	plan_properties.plan_expiry = time_rumour.rumour_subject_expiry
	plan_properties.plan_subject_character = mission_rumour.rumour_subject_character
	plan_properties.plan_subject_poi = location_rumour.rumour_subject_poi
	plan_properties.plan_effect = mission_rumour.rumour_effect

	# Create a new plan
	var plan = Plan.new(plan_properties)

	# Delete the rumours
	mission_rumour.queue_free()
	location_rumour.queue_free()
	time_rumour.queue_free()
	
	# for rumour in rumours:
	# 	match rumour.rumour_type:
	# 		Enums.RumourType.MISSION:
	# 			mission_rumour = rumour
	# 		Enums.RumourType.LOCATION:
	# 			location_rumour = rumour
	# 		Enums.RumourType.TIME:
	# 			time_rumour = rumour
	
	# # Validate we have all required rumours
	# if !mission_rumour or !location_rumour or !time_rumour:
	# 	push_error("Missing required rumours to formulate plan")
	# 	return null
	
	# # Set plan properties based on rumours
	# plan.plan_who_what = Globals.get_intel_effect_string(mission_rumour.rumour_effect, true)
	# plan.plan_where = Globals.get_intel_effect_string(location_rumour.rumour_effect, true)
	# plan.plan_when = Globals.get_intel_effect_string(time_rumour.rumour_effect, true)
	
	# # Set plan name (could be more sophisticated)
	# plan.plan_name = "Operation " + str(randi() % 1000)
	
	return plan
