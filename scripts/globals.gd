extends Node

#|==============================|
#|      Scene References       |
#|==============================|
"""
@brief Preloaded scene references for UI elements
"""
var confirmation_dialog_scene = preload("res://scenes/gui/confirmation_dialog.tscn")
var agent_card_scene = preload("res://scenes/gui/agent_card.tscn")
var mini_agent_card_scene = preload("res://scenes/gui/mini_agent_card.tscn")
var radial_menu_scene = preload("res://scenes/gui/radial_menu.tscn")
var character_list_scene = preload("res://scenes/gui/character_list.tscn")
var intel_list_scene = preload("res://scenes/gui/intel_list.tscn")
var log_list_scene = preload("res://scenes/gui/log_list.tscn")
var town_details_list_scene = preload("res://scenes/gui/town_details_list.tscn")
var actions_list_scene = preload("res://scenes/gui/actions_list.tscn")
var post_radial_assignment_scene = preload("res://scenes/gui/post_radial_assignment.tscn")
var actions_list_action_scene = preload("res://scenes/gui/actions_list_action.tscn")
var plan_scene = preload("res://scenes/gui/plan.tscn")
var event_panel_scene = preload("res://scenes/gui/event_panel.tscn")
var action_scene = preload("res://scenes/gui/action.tscn")

#|==============================|
#|       Data Sources          |
#|==============================|
"""
@brief Paths to CSV data files
"""
var load_csvs = {
	"town_names": "res://data/town_names.csv",
	"district_names": "res://data/district_names.csv",
	"first_names": "res://data/first_names.csv",
	"last_names": "res://data/last_names.csv",
	"poi_types": "res://data/poi_types.csv",
	"poi_names": "res://data/poi_names.csv",
	"rumour_text": "res://data/rumour_text.csv",
	"items": "res://data/items.csv",
	"event_outcome_text": "res://data/event_outcome_text.csv",
}

#|==============================|
#|      Cached Data Lists      |
#|==============================|
"""
@brief Arrays storing loaded data from CSVs
"""
var town_names = []
var district_names = []
var first_names = []
var last_names = []
var poi_types = []
var poi_names = []
var rumour_text = []
var event_outcome_text = {}

#|==============================|
#|      Data Loading           |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Loads all CSV data into memory.
"""
func _ready() -> void:
	_load_town_names(load_csvs["town_names"])
	_load_district_names(load_csvs["district_names"])
	_load_first_names(load_csvs["first_names"])
	_load_last_names(load_csvs["last_names"])
	_load_poi_types(load_csvs["poi_types"])
	_load_poi_names(load_csvs["poi_names"])
	_load_rumour_text(load_csvs["rumour_text"])
	_load_event_outcome_text(load_csvs["event_outcome_text"])

"""
@brief Loads town names from CSV
@param path Path to the CSV file
"""
func _load_town_names(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		town_names.append(record["town_name"])
	
func _load_district_names(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		district_names.append(record["district_name"])

func _load_first_names(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		var gender = gender_map[record["gender"].to_upper()]
		var nationality = nationality_map[record["nationality"].to_upper()]
		first_names.append({
			"first_name": record["first_name"],
			"gender": gender,
			"nationality": nationality
		})

func _load_last_names(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		var nationality = nationality_map[record["nationality"].to_upper()]
		last_names.append({
			"last_name": record["last_name"],
			"nationality": nationality
		})

func _load_poi_types(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		var poi_type = poi_type_map[record["poi_name"].replace(" ", "_").to_upper()]
		var district_type = []
		for type in record["district_type"].split(","):
			district_type.append(district_type_map[type.strip_edges().to_upper()])
		var skill_required = poi_skill_required_map[record["skill_required"].to_upper()]
		var bonus_type = poi_bonus_map[record["bonus_type"].to_upper()]
		poi_types.append({
			"poi_type": poi_type,
			"poi_name": record["poi_name"],
			"poi_description": record["poi_description"],
			"district_type": district_type,
			"spawn_chance": record["spawn_chance"],
			"max_spawn_quantity": record["max_spawn_quantity"],
			"skill_required": skill_required,
			"bonus_type": bonus_type,
			"what_chance": record["what_chance"],
			"where_chance": record["where_chance"],
			"when_chance": record["when_chance"]
		})
	
func _load_poi_names(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		var poi_type = poi_type_map[record["poi_type"].to_upper()]
		poi_names.append({
			"poi_type": poi_type,
			"poi_name": record["poi_name"],
		})

func _load_rumour_text(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		var type = rumour_map[record["type"].to_upper()]
		rumour_text.append({
			"text": record["text"],
			"type": type,
			"effect": intel_effect_map[record['effect'].to_upper()],
			"subject": rumour_subject_map[record['subject'].to_upper()]
		})

func _load_event_outcome_text(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		var category = event_outcome_category_map[record["event_category"].to_upper()]
		var title = record["event_title"]
		var text = record["event_text"]
		var button_text = record["event_button_text"]

		if not event_outcome_text.has(category):
			event_outcome_text[category] = []

		event_outcome_text[category].append({
			"category": category,
			"title": title,
			"text": text,
			"button_text": button_text
		})
#|==============================|
#|      Data Retrieval         |
#|==============================|
"""
@brief Retrieves all last names for a given nationality
@param nationality The nationality to filter by
@returns Array of last names
"""
func get_all_last_names(nationality: Enums.CharacterNationality) -> Array:
	return last_names.filter(func(name): return name.nationality == nationality)

"""
@brief Retrieves all first names for a given gender and nationality
@param gender The gender to filter by
@param nationality The nationality to filter by
@returns Array of first names
"""
func get_all_first_names(gender: Enums.CharacterGender, nationality: Enums.CharacterNationality) -> Array:
	return first_names.filter(func(name): return name.gender == gender and name.nationality == nationality)

"""
@brief Gets random rumour data of specified type
@param type The type of rumour to get
@returns Dictionary containing rumour data
"""
func get_rumour_data(type: Enums.RumourType) -> Dictionary:
	var filtered_rumour_text = rumour_text.filter(
		func(record):
			return record.type == type
	)
	return filtered_rumour_text[randi() % filtered_rumour_text.size()]

"""
@brief Retrieves all POI types for a given district type
@param district_type The district type to filter by
@returns Array of POI types
"""
func get_poi_types(district_type: Enums.DistrictType) -> Array:
	var filtered_poi_types = poi_types.filter(
		func(record):
			return record.district_type.has(district_type)
	)
	return filtered_poi_types

"""
@brief Retrieves the name of a POI type
@param poi_type The POI type to get the name of
@returns The name of the POI type
"""
func get_poi_name(poi_type: Enums.POIType) -> String:
	var filtered_poi_names = poi_names.filter(
		func(record):
			return record.poi_type == poi_type
	)
	return filtered_poi_names[randi() % filtered_poi_names.size()].poi_name

"""
@brief Gets the next profile picture for a given nationality and gender
@param nationality The nationality to get a profile picture for
@param gender The gender to get a profile picture for
@returns A profile picture resource
"""
func get_next_profile_image(nationality: Enums.CharacterNationality, gender: Enums.CharacterGender) -> Resource:
	# Create a unique key for this nationality/gender combination
	var pool_key = str(nationality) + "_" + str(gender)
	
	# Initialize the pool if it doesn't exist
	if not profile_images.has("pools"):
		profile_images["pools"] = {}
	
	if not profile_images.pools.has(pool_key) or profile_images.pools[pool_key].is_empty():
		# Create a new shuffled pool from the source images
		var source_images = profile_images[nationality][gender].duplicate()
		source_images.shuffle()
		profile_images.pools[pool_key] = source_images
	
	# Return and remove the last image from the pool
	return profile_images.pools[pool_key].pop_back()

#|==============================|
#|      Enum Mappings          |
#|==============================|
"""
@brief Maps string values to enum values for various types
"""
var gender_map = {
	"MALE": Enums.CharacterGender.MALE,
	"FEMALE": Enums.CharacterGender.FEMALE
}

var nationality_map = {
	"GERMAN": Enums.CharacterNationality.GERMAN,
	"BELGIAN": Enums.CharacterNationality.BELGIAN,
	"BRITISH": Enums.CharacterNationality.BRITISH,
	"FRENCH": Enums.CharacterNationality.FRENCH
}

var poi_type_map = {
	"CINEMA": Enums.POIType.CINEMA,
	"GROCER": Enums.POIType.GROCER,
	"SHOP": Enums.POIType.SHOP,
	"PUB": Enums.POIType.PUB,
	"RESTAURANT": Enums.POIType.RESTAURANT,
	"RESIDENCE": Enums.POIType.RESIDENCE,
	"FACTORY": Enums.POIType.FACTORY,
	"WORKSHOP": Enums.POIType.WORKSHOP,
	"WAREHOUSE": Enums.POIType.WAREHOUSE,
	"OFFICE": Enums.POIType.OFFICE,
	"ANTI_AIR_EMPLACEMENT": Enums.POIType.ANTI_AIR_EMPLACEMENT,
	"ANTI AIR EMPLACEMENT": Enums.POIType.ANTI_AIR_EMPLACEMENT,
	"CHURCH": Enums.POIType.CHURCH,
	"GESTAPO_POST": Enums.POIType.GESTAPO_POST,
	"GESTAPO POST": Enums.POIType.GESTAPO_POST,
	"CAFE": Enums.POIType.CAFE,
	"GESTAPO_HQ": Enums.POIType.GESTAPO_HQ,
	"GESTAPO HQ": Enums.POIType.GESTAPO_HQ,
	"TOWN_HALL": Enums.POIType.TOWN_HALL,
	"PARK": Enums.POIType.PARK,
	"POST_OFFICE": Enums.POIType.POST_OFFICE,
	"POST OFFICE": Enums.POIType.POST_OFFICE,
	"POLICE_STATION": Enums.POIType.POLICE_STATION,
	"POLICE STATION": Enums.POIType.POLICE_STATION,
	"TRAIN_STATION": Enums.POIType.TRAIN_STATION,
	"TRAIN STATION": Enums.POIType.TRAIN_STATION,
	"DOCKS": Enums.POIType.DOCKS,
	"BROTHEL": Enums.POIType.BROTHEL,
	"SUBMARINE_PEN": Enums.POIType.SUBMARINE_PEN,
	"SUBMARINE PEN": Enums.POIType.SUBMARINE_PEN,
	"CATHEDRAL": Enums.POIType.CATHEDRAL,
	"AIR_BASE": Enums.POIType.AIR_BASE,
	"GARRISON": Enums.POIType.GARRISON,
	"AMMO_FACTORY": Enums.POIType.AMMO_FACTORY,
	"AMMO FACTORY": Enums.POIType.AMMO_FACTORY,
	"FOUNDRY": Enums.POIType.FOUNDRY
}

var district_type_map = {
	"CIVIC": Enums.DistrictType.CIVIC,
	"INDUSTRIAL": Enums.DistrictType.INDUSTRIAL,
	"RESIDENTIAL": Enums.DistrictType.RESIDENTIAL,
	"PORT": Enums.DistrictType.PORT,
	"MILITARY": Enums.DistrictType.MILITARY
}

var rumour_map = {
	"MISSION": Enums.RumourType.MISSION,
	"LOCATION": Enums.RumourType.LOCATION,
	"TIME": Enums.RumourType.TIME,
	"WILDCARD": Enums.RumourType.WILDCARD
}

var rumour_subject_map = {
	"ANY_CHARACTER": Enums.RumourSubject.ANY_CHARACTER,
	"NON_SYMPATHISER_CHARACTER": Enums.RumourSubject.NON_SYMPATHISER_CHARACTER,
	"SYMPATHISER_CHARACTER": Enums.RumourSubject.SYMPATHISER_CHARACTER,
	"MIA_CHARACTER": Enums.RumourSubject.MIA_CHARACTER,
	"INJURED_CHARACTER": Enums.RumourSubject.INJURED_CHARACTER,
	"ANY_POI": Enums.RumourSubject.ANY_POI,
	"NONE": Enums.RumourSubject.NONE
}

var intel_effect_map = {
	"ADD_AGENT_SLOT": Enums.IntelEffect.ADD_AGENT_SLOT,
	"BUILD_SYMPATHY": Enums.IntelEffect.BUILD_SYMPATHY,
	"BUILD_SYMPATHY_ALL": Enums.IntelEffect.BUILD_SYMPATHY_ALL,
	"DISCOVER_ALL": Enums.IntelEffect.DISCOVER_ALL,
	"INCREASE_DIFFICULTY": Enums.IntelEffect.INCREASE_DIFFICULTY,
	"REDUCE_DIFFICULTY": Enums.IntelEffect.REDUCE_DIFFICULTY,
	"REDUCE_HEAT": Enums.IntelEffect.REDUCE_HEAT,
	"REDUCE_HEAT_ALL": Enums.IntelEffect.REDUCE_HEAT_ALL,
	"RESCUE_AGENT": Enums.IntelEffect.RESCUE_AGENT,
	"WILDCARD_INTEL": Enums.IntelEffect.WILDCARD_INTEL,
	"D_ONE_E_ONE": Enums.IntelEffect.D_ONE_E_ONE,
	"D_ONE_E_TWO": Enums.IntelEffect.D_ONE_E_TWO,
	"D_ONE_E_THREE": Enums.IntelEffect.D_ONE_E_THREE,
	"D_ONE_E_FOUR": Enums.IntelEffect.D_ONE_E_FOUR,
	"D_TWO_E_ONE": Enums.IntelEffect.D_TWO_E_ONE,
	"D_TWO_E_TWO": Enums.IntelEffect.D_TWO_E_TWO,
	"D_TWO_E_THREE": Enums.IntelEffect.D_TWO_E_THREE,
	"D_TWO_E_FOUR": Enums.IntelEffect.D_TWO_E_FOUR,
	"D_THREE_E_ONE": Enums.IntelEffect.D_THREE_E_ONE,
	"D_THREE_E_TWO": Enums.IntelEffect.D_THREE_E_TWO,
	"D_THREE_E_THREE": Enums.IntelEffect.D_THREE_E_THREE,
	"D_THREE_E_FOUR": Enums.IntelEffect.D_THREE_E_FOUR,
	"D_FOUR_E_ONE": Enums.IntelEffect.D_FOUR_E_ONE,
	"D_FOUR_E_TWO": Enums.IntelEffect.D_FOUR_E_TWO,
	"D_FOUR_E_THREE": Enums.IntelEffect.D_FOUR_E_THREE,
	"D_FOUR_E_FOUR": Enums.IntelEffect.D_FOUR_E_FOUR,
	"NONE": Enums.IntelEffect.NONE
}

var poi_skill_required_map = {
	"SUBTLETY": Enums.POISkillRequired.SUBTLETY,
	"SMARTS": Enums.POISkillRequired.SMARTS,
	"CHARM": Enums.POISkillRequired.CHARM,
	"NONE": Enums.POISkillRequired.NONE
}

var poi_bonus_map = {
	"NONE": Enums.POIBonusType.NONE
}

var event_outcome_category_map = {
	"MIA": Enums.EventOutcomeType.MIA,
	"INJURED": Enums.EventOutcomeType.INJURED,
	"DECEASED": Enums.EventOutcomeType.DECEASED,
	"NEW_SYMPATHISER": Enums.EventOutcomeType.NEW_SYMPATHISER,
	"HEAT_BREAKPOINT_MEDIUM": Enums.EventOutcomeType.HEAT_BREAKPOINT_MEDIUM,
	"HEAT_BREAKPOINT_HIGH": Enums.EventOutcomeType.HEAT_BREAKPOINT_HIGH,
	"EVENT_CIVIC_MILESTONE": Enums.EventOutcomeType.EVENT_CIVIC_MILESTONE,
	"EVENT_INDUSTRIAL_MILESTONE": Enums.EventOutcomeType.EVENT_INDUSTRIAL_MILESTONE,
	"EVENT_RESIDENTIAL_MILESTONE": Enums.EventOutcomeType.EVENT_RESIDENTIAL_MILESTONE,
	"EVENT_PORT_MILESTONE": Enums.EventOutcomeType.EVENT_PORT_MILESTONE,
	"EVENT_MILITARY_MILESTONE": Enums.EventOutcomeType.EVENT_MILITARY_MILESTONE
}

#|==============================|
#|    String Conversions       |
#|==============================|
"""
@brief Converts enum values to human-readable strings
"""
func get_action_type_string(action_type: Enums.ActionType) -> String:
	match action_type:
		Enums.ActionType.NONE:
			return "None"
		Enums.ActionType.ESPIONAGE:
			return "Espionage"
		Enums.ActionType.SURVEILLANCE:
			return "Surveillance"
		Enums.ActionType.PROPAGANDA:
			return "Propaganda"
		_:
			return "Unknown"

func get_intel_type_string(intel_type: Enums.RumourType) -> String:
	match intel_type:
		Enums.RumourType.MISSION:
			return "Mission"
		Enums.RumourType.LOCATION:
			return "Location"
		Enums.RumourType.TIME:
			return "Time"
		Enums.RumourType.WILDCARD:
			return "Wildcard"
		_:
			return "Unknown"

func get_intel_effect_string(effect, bbcode_enabled: bool = false) -> String:

	match effect:
		Enums.IntelEffect.ADD_AGENT_SLOT:
			return "+1 Agent Slot"
		Enums.IntelEffect.BUILD_SYMPATHY:
			return "+20 Character Sympathy"
		Enums.IntelEffect.BUILD_SYMPATHY_ALL:
			return "+5 Character Sympathy in District"
		Enums.IntelEffect.DISCOVER_ALL:
			return "Reveal all Characters in District"
		Enums.IntelEffect.INCREASE_DIFFICULTY:
			return "Increased Difficulty"
		Enums.IntelEffect.REDUCE_DIFFICULTY:
			return "Reduced Difficulty"
		Enums.IntelEffect.REDUCE_HEAT:
			return "-20 District Heat"
		Enums.IntelEffect.REDUCE_HEAT_ALL:
			return "-5 Heat in all District"
		Enums.IntelEffect.RESCUE_AGENT:
			return "Rescue MIA Agent"
		Enums.IntelEffect.WILDCARD_INTEL:
			return "+1 Wildcard Intel"
		Enums.IntelEffect.D_ONE_E_ONE:
			if bbcode_enabled:
				return "Duration: 1 Day\nExpiry: 1 Day"
			else:
				return "Duration: 1 Day, Expiry: 1 Day"
		Enums.IntelEffect.D_ONE_E_TWO:
			if bbcode_enabled:
				return "Duration: 1 Day\nExpiry: 2 Days"
			else:
				return "Duration: 1 Day, Expiry: 2 Days"
		Enums.IntelEffect.D_ONE_E_THREE:
			if bbcode_enabled:
				return "Duration: 1 Day\nExpiry: 3 Days"
			else:
				return "Duration: 1 Day, Expiry: 3 Days"
		Enums.IntelEffect.D_ONE_E_FOUR:
			if bbcode_enabled:
				return "Duration: 1 Day\nExpiry: 4 Days"
			else:
				return "Duration: 1 Day, Expiry: 4 Days"
		Enums.IntelEffect.D_TWO_E_ONE:
			if bbcode_enabled:
				return "Duration: 2 Days\nExpiry: 1 Day"
			else:
				return "Duration: 2 Days, Expiry: 1 Day"
		Enums.IntelEffect.D_TWO_E_TWO:
			if bbcode_enabled:
				return "Duration: 2 Days\nExpiry: 2 Days"
			else:
				return "Duration: 2 Days, Expiry: 2 Days"
		Enums.IntelEffect.D_TWO_E_THREE:
			if bbcode_enabled:
				return "Duration: 2 Days\nExpiry: 3 Days"
			else:
				return "Duration: 2 Days, Expiry: 3 Days"
		Enums.IntelEffect.D_TWO_E_FOUR:
			if bbcode_enabled:
				return "Duration: 2 Days\nExpiry: 4 Days"
			else:
				return "Duration: 2 Days, Expiry: 4 Days"
		Enums.IntelEffect.D_THREE_E_ONE:
			if bbcode_enabled:
				return "Duration: 3 Days\nExpiry: 1 Day"
			else:
				return "Duration: 3 Days, Expiry: 1 Day"
		Enums.IntelEffect.D_THREE_E_TWO:
			if bbcode_enabled:
				return "Duration: 3 Days\nExpiry: 2 Days"
			else:
				return "Duration: 3 Days, Expiry: 2 Days"
		Enums.IntelEffect.D_THREE_E_THREE:
			if bbcode_enabled:
				return "Duration: 3 Days\nExpiry: 3 Days"
			else:
				return "Duration: 3 Days, Expiry: 3 Days"
		Enums.IntelEffect.D_THREE_E_FOUR:
			if bbcode_enabled:
				return "Duration: 3 Days\nExpiry: 4 Days"
			else:
				return "Duration: 3 Days, Expiry: 4 Days"
		Enums.IntelEffect.D_FOUR_E_ONE:
			if bbcode_enabled:
				return "Duration: 4 Days\nExpiry: 1 Day"
			else:
				return "Duration: 4 Days, Expiry: 1 Day"
		Enums.IntelEffect.D_FOUR_E_TWO:
			if bbcode_enabled:
				return "Duration: 4 Days\nExpiry: 2 Days"
			else:
				return "Duration: 4 Days, Expiry: 2 Days"
		Enums.IntelEffect.D_FOUR_E_THREE:
			if bbcode_enabled:
				return "Duration: 4 Days\nExpiry: 3 Days"
			else:
				return "Duration: 4 Days, Expiry: 3 Days"
		Enums.IntelEffect.D_FOUR_E_FOUR:
			if bbcode_enabled:
				return "Duration: 4 Days\nExpiry: 4 Days"
			else:
				return "Duration: 4 Days, Expiry: 4 Days"
		Enums.IntelEffect.NONE:
			return "None"
		_:
			return "Unknown"

func get_character_state_string(status: Enums.CharacterState) -> String:
	match status:
		Enums.CharacterState.AVAILABLE:
			return "None"
		Enums.CharacterState.ASSIGNED:
			return "Assigned"
		Enums.CharacterState.MIA:
			return "MIA"
		Enums.CharacterState.INJURED:
			return "Injured"
		Enums.CharacterState.DECEASED:
			return "Deceased"
		_:
			return "Unknown"
		
func get_nationality_string(nationality: Enums.CharacterNationality) -> String:
	match nationality:
		Enums.CharacterNationality.GERMAN:
			return "German"
		Enums.CharacterNationality.BELGIAN:
			return "Belgian"
		Enums.CharacterNationality.BRITISH:
			return "British"
		Enums.CharacterNationality.FRENCH:
			return "French"
		_:
			return "Unknown"
	
func get_profession_string(profession: Enums.CharacterProfession) -> String:
	match profession:
		Enums.CharacterProfession.UNKNOWN:
			return "Unknown"
		_:
			return "Unknown"

func get_poi_bonus_string(bonus: Enums.POIBonusType) -> String:
	match bonus:
		Enums.POIBonusType.NONE:
			return "None"
		_:
			return "Unknown"

func get_district_type_string(district_type: Enums.DistrictType) -> String:
	match district_type:
		Enums.DistrictType.CIVIC:
			return "Civic"
		Enums.DistrictType.INDUSTRIAL:
			return "Industrial"
		Enums.DistrictType.RESIDENTIAL:
			return "Residential"
		Enums.DistrictType.PORT:
			return "Port"
		Enums.DistrictType.MILITARY:
			return "Military"
		_:
			return "Unknown"

#|==============================|
#|      Asset References       |
#|==============================|
"""
@brief Preloaded profile images organized by nationality and gender
"""
var profile_images = {
	Enums.CharacterNationality.GERMAN: {
		Enums.CharacterGender.MALE: [
			preload("res://assets/profile_pictures/german/male/german-male-1.png"),
			preload("res://assets/profile_pictures/german/male/german-male-2.png"),
			preload("res://assets/profile_pictures/german/male/german-male-3.png"),
			preload("res://assets/profile_pictures/german/male/german-male-4.png"),
			preload("res://assets/profile_pictures/german/male/german-male-5.png"),
			preload("res://assets/profile_pictures/german/male/german-male-6.png"),
			preload("res://assets/profile_pictures/german/male/german-male-7.png"),
			preload("res://assets/profile_pictures/german/male/german-male-8.png"),
			preload("res://assets/profile_pictures/german/male/german-male-9.png"),
			preload("res://assets/profile_pictures/german/male/german-male-10.png"),
		],
		Enums.CharacterGender.FEMALE: [
			preload("res://assets/profile_pictures/german/female/german-female-1.png"),
			preload("res://assets/profile_pictures/german/female/german-female-2.png"),
			preload("res://assets/profile_pictures/german/female/german-female-3.png"),
			preload("res://assets/profile_pictures/german/female/german-female-4.png"),
			preload("res://assets/profile_pictures/german/female/german-female-5.png"),
			preload("res://assets/profile_pictures/german/female/german-female-6.png"),
			preload("res://assets/profile_pictures/german/female/german-female-7.png"),
			preload("res://assets/profile_pictures/german/female/german-female-8.png"),
			preload("res://assets/profile_pictures/german/female/german-female-9.png"),
			preload("res://assets/profile_pictures/german/female/german-female-10.png"),
			preload("res://assets/profile_pictures/german/female/german-female-11.png"),
		]
	},
	Enums.CharacterNationality.BELGIAN: {
		Enums.CharacterGender.MALE: [
			preload("res://assets/profile_pictures/belgian/male/belgian-male-1.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-2.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-3.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-4.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-5.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-6.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-7.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-8.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-9.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-10.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-11.png"),
		],
		Enums.CharacterGender.FEMALE: [
			preload("res://assets/profile_pictures/belgian/female/belgian-female-1.png"),
			preload("res://assets/profile_pictures/belgian/female/belgian-female-2.png"),
			preload("res://assets/profile_pictures/belgian/female/belgian-female-3.png"),
			preload("res://assets/profile_pictures/belgian/female/belgian-female-4.png"),
			preload("res://assets/profile_pictures/belgian/female/belgian-female-5.png"),
			preload("res://assets/profile_pictures/belgian/female/belgian-female-6.png"),
			preload("res://assets/profile_pictures/belgian/female/belgian-female-7.png"),
			preload("res://assets/profile_pictures/belgian/female/belgian-female-8.png"),
			preload("res://assets/profile_pictures/belgian/female/belgian-female-9.png"),
			preload("res://assets/profile_pictures/belgian/female/belgian-female-10.png"),
			preload("res://assets/profile_pictures/belgian/female/belgian-female-11.png"),
		]
	},
	Enums.CharacterNationality.FRENCH: {
		Enums.CharacterGender.MALE: [
			preload("res://assets/profile_pictures/french/male/french-male-1.png"),
			preload("res://assets/profile_pictures/french/male/french-male-2.png"),
			preload("res://assets/profile_pictures/french/male/french-male-3.png"),
			preload("res://assets/profile_pictures/french/male/french-male-4.png"),
			preload("res://assets/profile_pictures/french/male/french-male-5.png"),
			preload("res://assets/profile_pictures/french/male/french-male-6.png"),
			preload("res://assets/profile_pictures/french/male/french-male-7.png"),
			preload("res://assets/profile_pictures/french/male/french-male-8.png"),
			preload("res://assets/profile_pictures/french/male/french-male-9.png"),
			preload("res://assets/profile_pictures/french/male/french-male-10.png"),
			preload("res://assets/profile_pictures/french/male/french-male-11.png"),
			preload("res://assets/profile_pictures/french/male/french-male-12.png"),
		],
		Enums.CharacterGender.FEMALE: [
			preload("res://assets/profile_pictures/french/female/french-female-1.png"),
			preload("res://assets/profile_pictures/french/female/french-female-2.png"),
			preload("res://assets/profile_pictures/french/female/french-female-3.png"),
			preload("res://assets/profile_pictures/french/female/french-female-4.png"),
			preload("res://assets/profile_pictures/french/female/french-female-5.png"),
			preload("res://assets/profile_pictures/french/female/french-female-6.png"),
			preload("res://assets/profile_pictures/french/female/french-female-7.png"),
			preload("res://assets/profile_pictures/french/female/french-female-8.png"),
			preload("res://assets/profile_pictures/french/female/french-female-9.png"),
			preload("res://assets/profile_pictures/french/female/french-female-10.png"),
			preload("res://assets/profile_pictures/french/female/french-female-11.png"),
		]
	},
	Enums.CharacterNationality.BRITISH: {
		Enums.CharacterGender.MALE: [
			preload("res://assets/profile_pictures/british/male/british-male-1.png"),
			preload("res://assets/profile_pictures/british/male/british-male-2.png"),
			preload("res://assets/profile_pictures/british/male/british-male-3.png"),
			preload("res://assets/profile_pictures/british/male/british-male-4.png"),
			preload("res://assets/profile_pictures/british/male/british-male-5.png"),
			preload("res://assets/profile_pictures/british/male/british-male-6.png"),
			preload("res://assets/profile_pictures/british/male/british-male-7.png"),
			preload("res://assets/profile_pictures/british/male/british-male-8.png"),
			preload("res://assets/profile_pictures/british/male/british-male-9.png"),
			preload("res://assets/profile_pictures/british/male/british-male-10.png"),
			preload("res://assets/profile_pictures/british/male/british-male-11.png"),
		],
		Enums.CharacterGender.FEMALE: [
			preload("res://assets/profile_pictures/british/female/british-female-1.png"),
			preload("res://assets/profile_pictures/british/female/british-female-2.png"),
			preload("res://assets/profile_pictures/british/female/british-female-3.png"),
			preload("res://assets/profile_pictures/british/female/british-female-4.png"),
			preload("res://assets/profile_pictures/british/female/british-female-5.png"),
			preload("res://assets/profile_pictures/british/female/british-female-6.png"),
			preload("res://assets/profile_pictures/british/female/british-female-7.png"),
			preload("res://assets/profile_pictures/british/female/british-female-8.png"),
		]
	},
}

var event_images = {
	Enums.EventOutcomeType.MIA: preload("res://assets/sprites/events/event_mia.png"),
	Enums.EventOutcomeType.INJURED: preload("res://assets/sprites/events/event_injured.png"),
	Enums.EventOutcomeType.DECEASED: preload("res://assets/sprites/events/event_deceased.png"),
	Enums.EventOutcomeType.NEW_SYMPATHISER: preload("res://assets/sprites/events/event_new_sympathiser.png"),
	Enums.EventOutcomeType.HEAT_BREAKPOINT_MEDIUM: preload("res://assets/sprites/events/event_heat_breakpoint_medium.png"),
	Enums.EventOutcomeType.HEAT_BREAKPOINT_HIGH: preload("res://assets/sprites/events/event_heat_breakpoint_high.png"),
	Enums.EventOutcomeType.EVENT_CIVIC_MILESTONE: preload("res://assets/sprites/events/event_blank.png"), #TODO: Add civic milestone image
	Enums.EventOutcomeType.EVENT_INDUSTRIAL_MILESTONE: preload("res://assets/sprites/events/event_blank.png"), #TODO: Add industrial milestone image
	Enums.EventOutcomeType.EVENT_RESIDENTIAL_MILESTONE: preload("res://assets/sprites/events/event_blank.png"), #TODO: Add residential milestone image
	Enums.EventOutcomeType.EVENT_PORT_MILESTONE: preload("res://assets/sprites/events/event_blank.png"), #TODO: Add port milestone image
	Enums.EventOutcomeType.EVENT_MILITARY_MILESTONE: preload("res://assets/sprites/events/event_blank.png"), #TODO: Add military milestone image
}
