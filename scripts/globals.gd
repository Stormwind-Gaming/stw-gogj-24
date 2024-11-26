extends Node

#|==============================|
#|      Theme References       |
#|==============================|

var base_theme = preload("res://assets/themes/base_theme.tres")
var dark_theme = preload("res://assets/themes/dark_theme.tres")

#|==============================|
#|      Shader References       |
#|==============================|

"""
@brief Preloaded shader references
"""
var black_to_white_shader = preload("res://assets/shaders/black_to_white.gdshader")

#|==============================|
#|      Scene References       |
#|==============================|
"""
@brief Preloaded scene references for UI elements
"""
var confirmation_dialog_scene = preload("res://scenes/gui/menus/confirmation_dialog.tscn")
var agent_card_scene = preload("res://scenes/gui/agent_cards/agent_card.tscn")
var mini_agent_card_scene = preload("res://scenes/gui/agent_cards/mini_agent_card.tscn")
var blank_agent_card_scene = preload("res://scenes/gui/agent_cards/blank_agent_card.tscn")
var radial_menu_scene = preload("res://scenes/gui/menus/radial_menu.tscn")
var character_list_scene = preload("res://scenes/gui/menus/character_list.tscn")
var intel_list_scene = preload("res://scenes/gui/menus/intel_list.tscn")
var log_list_scene = preload("res://scenes/gui/menus/log_list.tscn")
var town_details_list_scene = preload("res://scenes/gui/menus/town_menus/town_details_list.tscn")
var actions_list_scene = preload("res://scenes/gui/menus/actions_list.tscn")
var post_radial_assignment_scene = preload("res://scenes/gui/menus/post_radial_assignment.tscn")
var actions_list_action_scene = preload("res://scenes/gui/menus/actions_list_action.tscn")
var plan_scene = preload("res://scenes/gui/menus/plan.tscn")
var event_panel_scene = preload("res://scenes/gui/menus/event_panel.tscn")
var action_scene = preload("res://scenes/gui/action.tscn")
var day_log_scene = preload("res://scenes/gui/menus/day_log.tscn")

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
	"world_event_text": "res://data/world_event_text.csv",
	"end_screen_text": "res://data/end_screen_text.csv"
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
var world_event_text = []
var endgame_text = []
#|==============================|
#|      Data Loading           |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Loads all CSV data into memory.
"""
func _ready() -> void:
	LogDuck.d("Globals: Starting data loading")
	_load_town_names(load_csvs["town_names"])
	_load_district_names(load_csvs["district_names"])
	_load_first_names(load_csvs["first_names"])
	_load_last_names(load_csvs["last_names"])
	_load_poi_types(load_csvs["poi_types"])
	_load_poi_names(load_csvs["poi_names"])
	_load_rumour_text(load_csvs["rumour_text"])
	_load_event_outcome_text(load_csvs["event_outcome_text"])
	_load_world_event_text(load_csvs["world_event_text"])
	_load_end_screen_text(load_csvs["end_screen_text"])
	LogDuck.d("Globals: Completed data loading")

"""
@brief Loads town names from CSV
@param path Path to the CSV file
"""
func _load_town_names(path: String) -> void:
	LogDuck.d("Globals: Loading town names from %s" % path)
	var csv_data = load(path)
	for record in csv_data.records:
		town_names.append(record["town_name"])
	LogDuck.d("Globals: Loaded %d town names" % town_names.size())
	
func _load_district_names(path: String) -> void:
	LogDuck.d("Globals: Loading district names from %s" % path)
	var csv_data = load(path)
	for record in csv_data.records:
		district_names.append(record["district_name"])
	LogDuck.d("Globals: Loaded %d district names" % district_names.size())

func _load_first_names(path: String) -> void:
	LogDuck.d("Globals: Loading first names from %s" % path)
	var csv_data = load(path)
	for record in csv_data.records:
		var gender = gender_map[record["gender"].to_upper()]
		var nationality = nationality_map[record["nationality"].to_upper()]
		first_names.append({
			"first_name": record["first_name"],
			"gender": gender,
			"nationality": nationality
		})
	LogDuck.d("Globals: Loaded %d first names" % first_names.size())

func _load_last_names(path: String) -> void:
	LogDuck.d("Globals: Loading last names from %s" % path)
	var csv_data = load(path)
	for record in csv_data.records:
		var nationality = nationality_map[record["nationality"].to_upper()]
		last_names.append({
			"last_name": record["last_name"],
			"nationality": nationality
		})
	LogDuck.d("Globals: Loaded %d last names" % last_names.size())

func _load_poi_types(path: String) -> void:
	LogDuck.d("Globals: Loading POI types from %s" % path)
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
			"poi_profession": record["poi_profession"],
			"poi_short_description": record["poi_short_description"],
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
	LogDuck.d("Globals: Loaded %d POI types" % poi_types.size())
	
func _load_poi_names(path: String) -> void:
	LogDuck.d("Globals: Loading POI names from %s" % path)
	var csv_data = load(path)
	for record in csv_data.records:
		var poi_type = poi_type_map[record["poi_type"].to_upper()]
		poi_names.append({
			"poi_type": poi_type,
			"poi_name": record["poi_name"],
		})
	LogDuck.d("Globals: Loaded %d POI names" % poi_names.size())

func _load_rumour_text(path: String) -> void:
	LogDuck.d("Globals: Loading rumour text from %s" % path)
	var csv_data = load(path)
	for record in csv_data.records:
		var type = rumour_map[record["type"].to_upper()]
		
		rumour_text.append({
			"text": record["text"],
			"type": type,
			"effect": intel_effect_map[record['effect'].to_upper()],
			"subject": rumour_subject_map[record['subject'].to_upper()]
		})
	LogDuck.d("Globals: Loaded %d rumour texts" % rumour_text.size())

func _load_event_outcome_text(path: String) -> void:
	LogDuck.d("Globals: Loading event outcome text from %s" % path)
	var csv_data = load(path)
	var count = 0
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
		count += 1
	LogDuck.d("Globals: Loaded %d event outcome texts" % count)

func _load_world_event_text(path: String) -> void:
	LogDuck.d("Globals: Loading world event text from %s" % path)
	var csv_data = load(path)
	for record in csv_data.records:
		world_event_text.append({
			"event_severity": world_event_category_map[record["event_severity"].to_upper().strip_edges()],
			"event_type": world_event_type_map[record["event_type"].to_upper().strip_edges()],
			"event_text": record["event_text"].strip_edges(),
			"effect_text": record["effect_text"].strip_edges(),
			"event_end_text": record["event_end_text"].strip_edges(),
			"event_title": record["event_title"].strip_edges(),
			"event_button_text": record["event_button_text"].strip_edges()
		})
	LogDuck.d("Globals: Loaded %d world event texts" % world_event_text.size())

func _load_end_screen_text(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		var category = event_outcome_category_map[record["endgame_event"].to_upper()]
		var text = record["endgame_text"]

		endgame_text.append({
			"category": category,
			"text": text,
		})
	LogDuck.d("Globals: Loaded %d end screen texts" % endgame_text.size())

#|==============================|
#|      Data Retrieval         |
#|==============================|
"""
@brief Retrieves all last names for a given nationality
@param nationality The nationality to filter by
@returns Array of last names
"""
func get_all_last_names(nationality: Enums.CharacterNationality) -> Array:
	return last_names.filter(func(char_name): return char_name.nationality == nationality)

"""
@brief Retrieves all first names for a given gender and nationality
@param gender The gender to filter by
@param nationality The nationality to filter by
@returns Array of first names
"""
func get_all_first_names(gender: Enums.CharacterGender, nationality: Enums.CharacterNationality) -> Array:
	return first_names.filter(func(char_name): return char_name.gender == gender and char_name.nationality == nationality)

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

"""
@brief Gets the text for a world event of a given severity
@param severity The severity of the world event to get the text for
@returns The text for the world event
"""
func get_world_event_text(severity: Enums.WorldEventSeverity):
	var world_event_text_copy = world_event_text.duplicate()
	var filtered_world_event_text = world_event_text_copy.filter(
		func(record):
			print(record.event_severity, severity, record.event_severity == severity)
			return record.event_severity == severity
	)
	# If no text is found, return null to prevent error
	if filtered_world_event_text.size() == 0:
		return null
	return filtered_world_event_text[randi() % filtered_world_event_text.size()]

"""
@brief Gets the text for an endgame event of a given category
@param category The category of the endgame event to get the text for
@returns The text for the endgame event
"""
func get_endgame_text(category: Enums.EventOutcomeType):
	# there is only one text per category
	return endgame_text.filter(func(record): return record.category == category)[0].text

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
	"ANTI-AIR_EMPLACEMENT": Enums.POIType.ANTI_AIR_EMPLACEMENT,
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
	"EVENT_MILITARY_MILESTONE": Enums.EventOutcomeType.EVENT_MILITARY_MILESTONE,
	"SYMPATHY_BREAKPOINT_LOW": Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_LOW,
	"SYMPATHY_BREAKPOINT_MEDIUM": Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_MEDIUM,
	"SYMPATHY_BREAKPOINT_HIGH": Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_HIGH,
	"WORLD_EVENT_MINOR_INCREASED_PATROLS": Enums.EventOutcomeType.WORLD_EVENT_MINOR_INCREASED_PATROLS,
	"WORLD_EVENT_MINOR_SECRET_POLICE": Enums.EventOutcomeType.WORLD_EVENT_MINOR_SECRET_POLICE,
	"WORLD_EVENT_MINOR_AIRBASE": Enums.EventOutcomeType.WORLD_EVENT_MINOR_AIRBASE,
	"WORLD_EVENT_MINOR_INFORMER": Enums.EventOutcomeType.WORLD_EVENT_MINOR_INFORMER,
	"WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED": Enums.EventOutcomeType.WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED,
	"WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE": Enums.EventOutcomeType.WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE,
	"WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP": Enums.EventOutcomeType.WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP,
	"WORLD_EVENT_MAJOR_SECRET_POLICE": Enums.EventOutcomeType.WORLD_EVENT_MAJOR_SECRET_POLICE,
	"WORLD_EVENT_MAJOR_POLICE_COMMANDER": Enums.EventOutcomeType.WORLD_EVENT_MAJOR_POLICE_COMMANDER,
	"WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED": Enums.EventOutcomeType.WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED,
	# endgame
	"RESISTANCE_AIRFIELD_01": Enums.EventOutcomeType.RESISTANCE_AIRFIELD_01,
	"RESISTANCE_AIRFIELD_02": Enums.EventOutcomeType.RESISTANCE_AIRFIELD_02,
	"RESISTANCE_AIRFIELD_03": Enums.EventOutcomeType.RESISTANCE_AIRFIELD_03,
	"RESISTANCE_AIRFIELD_04": Enums.EventOutcomeType.RESISTANCE_AIRFIELD_04,
	"RESISTANCE_AIRFIELD_05": Enums.EventOutcomeType.RESISTANCE_AIRFIELD_05,
	"RESISTANCE_GENERAL_01": Enums.EventOutcomeType.RESISTANCE_GENERAL_01,
	"RESISTANCE_GENERAL_02": Enums.EventOutcomeType.RESISTANCE_GENERAL_02,
	"RESISTANCE_GENERAL_03": Enums.EventOutcomeType.RESISTANCE_GENERAL_03,
	"RESISTANCE_GENERAL_04": Enums.EventOutcomeType.RESISTANCE_GENERAL_04,
	"RESISTANCE_GENERAL_05": Enums.EventOutcomeType.RESISTANCE_GENERAL_05,
	"HEAT_01": Enums.EventOutcomeType.HEAT_01,
	"HEAT_PORT_02": Enums.EventOutcomeType.HEAT_PORT_02,
	"HEAT_PORT_03": Enums.EventOutcomeType.HEAT_PORT_03,
	"HEAT_PORT_04": Enums.EventOutcomeType.HEAT_PORT_04,
	"HEAT_TRAIN_02": Enums.EventOutcomeType.HEAT_TRAIN_02,
	"HEAT_TRAIN_03": Enums.EventOutcomeType.HEAT_TRAIN_03,
	"HEAT_TRAIN_04": Enums.EventOutcomeType.HEAT_TRAIN_04,
	"HEAT_TRAIN_SUCCESS": Enums.EventOutcomeType.HEAT_TRAIN_SUCCESS,
	"HEAT_PORT_SUCCESS": Enums.EventOutcomeType.HEAT_PORT_SUCCESS,
	"RESISTANCE_AIRFIELD_SUCCESS": Enums.EventOutcomeType.RESISTANCE_AIRFIELD_SUCCESS,
	"RESISTANCE_GENERAL_SUCCESS": Enums.EventOutcomeType.RESISTANCE_GENERAL_SUCCESS,
	"HEAT_TRAIN_FAILURE": Enums.EventOutcomeType.HEAT_TRAIN_FAILURE,
	"HEAT_PORT_FAILURE": Enums.EventOutcomeType.HEAT_PORT_FAILURE,
	"RESISTANCE_AIRFIELD_FAILURE": Enums.EventOutcomeType.RESISTANCE_AIRFIELD_FAILURE,
	"RESISTANCE_GENERAL_FAILURE": Enums.EventOutcomeType.RESISTANCE_GENERAL_FAILURE
}

var world_event_category_map = {
	"MINOR": Enums.WorldEventSeverity.MINOR,
	"SIGNIFICANT": Enums.WorldEventSeverity.SIGNIFICANT,
	"MAJOR": Enums.WorldEventSeverity.MAJOR
}

var world_event_type_map = {
	"WORLD_EVENT_MINOR_INCREASED_PATROLS": Enums.WorldEventType.MINOR_INCREASED_PATROLS,
	"WORLD_EVENT_MINOR_SECRET_POLICE": Enums.WorldEventType.MINOR_SECRET_POLICE,
	"WORLD_EVENT_MINOR_AIRBASE": Enums.WorldEventType.MINOR_AIRBASE,
	"WORLD_EVENT_MINOR_INFORMER": Enums.WorldEventType.MINOR_INFORMER,
	"WORLD_EVENT_SIGNIFICANT_SYMPATHISER_CAPTURED": Enums.WorldEventType.SIGNIFICANT_SYMPATHISER_CAPTURED,
	"WORLD_EVENT_SIGNIFICANT_WEAPONS_CACHE": Enums.WorldEventType.SIGNIFICANT_WEAPONS_CACHE,
	"WORLD_EVENT_SIGNIFICANT_MILITARY_SHIP": Enums.WorldEventType.SIGNIFICANT_MILITARY_SHIP,
	"WORLD_EVENT_MAJOR_SECRET_POLICE": Enums.WorldEventType.MAJOR_SECRET_POLICE,
	"WORLD_EVENT_MAJOR_POLICE_COMMANDER": Enums.WorldEventType.MAJOR_POLICE_COMMANDER,
	"WORLD_EVENT_MAJOR_SAFEHOUSE_DISCOVERED": Enums.WorldEventType.MAJOR_SAFEHOUSE_DISCOVERED
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


func get_stat_string(stat: Enums.StatCheckType) -> String:
	match stat:
		Enums.StatCheckType.SMARTS:
			return "Smarts"
		Enums.StatCheckType.CHARM:
			return "Charm"
		Enums.StatCheckType.SUBTLETY:
			return "Subtlety"
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

func get_district_type_bonus_string(district_type: Enums.DistrictType) -> String:
	match district_type:
		Enums.DistrictType.CIVIC:
			return "+1 to all Subtlety actions"
		Enums.DistrictType.INDUSTRIAL:
			return "+1 to all Smarts actions"
		Enums.DistrictType.RESIDENTIAL:
			return "+25% to all Sympathy gains"
		Enums.DistrictType.PORT:
			return "-25% to all Heat gains"
		Enums.DistrictType.MILITARY:
			return "+1 to all Charm actions"
		_:
			return "Unknown"

func get_district_type_base_effect_string(district_type: Enums.DistrictType) -> String:
	match district_type:
		Enums.DistrictType.CIVIC:
			return "+25% to all Heat gains"
		Enums.DistrictType.INDUSTRIAL:
			return "+10% injury chance"
		Enums.DistrictType.RESIDENTIAL:
			return "+10% Subtlety failure chance"
		Enums.DistrictType.PORT:
			return "+1 day to all action durations"
		Enums.DistrictType.MILITARY:
			return "-50% to all Sympathy gains."
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
	# Character Events
	Enums.EventOutcomeType.MIA: preload("res://assets/sprites/events/event_mia.png"),
	Enums.EventOutcomeType.INJURED: preload("res://assets/sprites/events/event_injured.png"),
	Enums.EventOutcomeType.DECEASED: preload("res://assets/sprites/events/event_deceased.png"),
	Enums.EventOutcomeType.NEW_SYMPATHISER: preload("res://assets/sprites/events/event_new_sympathiser.png"),
	# Heat / Sympathy Events
	Enums.EventOutcomeType.HEAT_BREAKPOINT_MEDIUM: preload("res://assets/sprites/events/event_heat_breakpoint_medium.png"),
	Enums.EventOutcomeType.HEAT_BREAKPOINT_HIGH: preload("res://assets/sprites/events/event_heat_breakpoint_high.png"),
	Enums.EventOutcomeType.EVENT_CIVIC_MILESTONE: preload("res://assets/sprites/events/event_civic_milestone.png"),
	Enums.EventOutcomeType.EVENT_INDUSTRIAL_MILESTONE: preload("res://assets/sprites/events/event_industrial_milestone.png"),
	Enums.EventOutcomeType.EVENT_RESIDENTIAL_MILESTONE: preload("res://assets/sprites/events/event_residential_milestone.png"),
	Enums.EventOutcomeType.EVENT_PORT_MILESTONE: preload("res://assets/sprites/events/event_port_milestone.png"),
	Enums.EventOutcomeType.EVENT_MILITARY_MILESTONE: preload("res://assets/sprites/events/event_military_milestone.png"),
	Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_LOW: preload("res://assets/sprites/events/sympathy_breakpoint_low.png"),
	Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_MEDIUM: preload("res://assets/sprites/events/sympathy_breakpoint_medium.png"),
	Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_HIGH: preload("res://assets/sprites/events/sympathy_breakpoint_high.png"),
}

var world_event_images = {
	# World Events
	Enums.WorldEventType.MINOR_INCREASED_PATROLS: preload("res://assets/sprites/events/event_minor_increased_patrols.png"),
	Enums.WorldEventType.MINOR_SECRET_POLICE: preload("res://assets/sprites/events/event_minor_secret_police.png"),
	Enums.WorldEventType.MINOR_AIRBASE: preload("res://assets/sprites/events/event_minor_airbase.png"),
	Enums.WorldEventType.MINOR_INFORMER: preload("res://assets/sprites/events/event_minor_informer.png"),
	Enums.WorldEventType.SIGNIFICANT_SYMPATHISER_CAPTURED: preload("res://assets/sprites/events/event_significant_sympathiser_captured.png"),
	Enums.WorldEventType.SIGNIFICANT_WEAPONS_CACHE: preload("res://assets/sprites/events/event_significant_weapons_cache.png"),
	Enums.WorldEventType.SIGNIFICANT_MILITARY_SHIP: preload("res://assets/sprites/events/event_significant_military_ship.png"),
	Enums.WorldEventType.MAJOR_SECRET_POLICE: preload("res://assets/sprites/events/event_major_secret_police.png"),
	Enums.WorldEventType.MAJOR_POLICE_COMMANDER: preload("res://assets/sprites/events/event_major_police_commander.png"),
	Enums.WorldEventType.MAJOR_SAFEHOUSE_DISCOVERED: preload("res://assets/sprites/events/event_major_safehouse_discovered.png"),
}

var endgame_event_images = {
	# heat
	Enums.EventOutcomeType.HEAT_01: preload("res://assets/sprites/events/endgame/heat/heat_01.png"),
	Enums.EventOutcomeType.HEAT_PORT_02: preload("res://assets/sprites/events/endgame/heat/heat_port_02.png"),
	Enums.EventOutcomeType.HEAT_PORT_03: preload("res://assets/sprites/events/endgame/heat/heat_port_03.png"),
	Enums.EventOutcomeType.HEAT_PORT_04: preload("res://assets/sprites/events/endgame/heat/heat_port_04.png"),
	Enums.EventOutcomeType.HEAT_TRAIN_02: preload("res://assets/sprites/events/endgame/heat/heat_train_02.png"),
	Enums.EventOutcomeType.HEAT_TRAIN_03: preload("res://assets/sprites/events/endgame/heat/heat_train_03.png"),
	Enums.EventOutcomeType.HEAT_TRAIN_04: preload("res://assets/sprites/events/endgame/heat/heat_train_04.png"),
	# resistance
	Enums.EventOutcomeType.RESISTANCE_AIRFIELD_01: preload("res://assets/sprites/events/event_heat_resistance.png"),
	Enums.EventOutcomeType.RESISTANCE_AIRFIELD_02: preload("res://assets/sprites/events/endgame/resistance/resistance_airfield_02.png"),
	Enums.EventOutcomeType.RESISTANCE_AIRFIELD_03: preload("res://assets/sprites/events/endgame/resistance/resistance_airfield_03.png"),
	Enums.EventOutcomeType.RESISTANCE_AIRFIELD_04: preload("res://assets/sprites/events/endgame/resistance/resistance_airfield_04.png"),
	Enums.EventOutcomeType.RESISTANCE_AIRFIELD_05: preload("res://assets/sprites/events/endgame/resistance/resistance_airfield_05.png"),
	Enums.EventOutcomeType.RESISTANCE_GENERAL_01: preload("res://assets/sprites/events/event_heat_resistance.png"),
	# Enums.EventOutcomeType.RESISTANCE_GENERAL_02: preload("res://assets/sprites/events/endgame/resistance/resistance_general_02.png"),
	# Enums.EventOutcomeType.RESISTANCE_GENERAL_03: preload("res://assets/sprites/events/endgame/resistance/resistance_general_03.png"),
	# Enums.EventOutcomeType.RESISTANCE_GENERAL_04: preload("res://assets/sprites/events/endgame/resistance/resistance_general_04.png"),
	# Enums.EventOutcomeType.RESISTANCE_GENERAL_05: preload("res://assets/sprites/events/endgame/resistance/resistance_general_05.png"),
	
}

var endgame_page_images = {
	# win
	Enums.EventOutcomeType.HEAT_PORT_SUCCESS: preload("res://assets/sprites/events/endgame/win_port.jpg"),
	Enums.EventOutcomeType.HEAT_TRAIN_SUCCESS: preload("res://assets/sprites/events/endgame/win_train.webp"),
	Enums.EventOutcomeType.RESISTANCE_AIRFIELD_SUCCESS: preload("res://assets/sprites/events/endgame/win_airfield.jpg"),
	Enums.EventOutcomeType.RESISTANCE_AIRFIELD_FAILURE: preload("res://assets/sprites/events/endgame/win_airfield.jpg"),
	# Enums.EventOutcomeType.RESISTANCE_GENERAL_SUCCESS: preload("res://assets/sprites/events/endgame/win_general.jpg"),
	# Enums.EventOutcomeType.RESISTANCE_GENERAL_FAILURE: preload("res://assets/sprites/events/endgame/win_general.jpg"),
	# lose
	Enums.EventOutcomeType.HEAT_PORT_FAILURE: preload("res://assets/sprites/events/endgame/lose_port.webp"),
	Enums.EventOutcomeType.HEAT_TRAIN_FAILURE: preload("res://assets/sprites/events/endgame/lose_train.webp"),
}


var poi_icons = {
	# Enums.POIType.NONE: preload("res://assets/icons/poi/selected/none.png"),
	Enums.POIType.GESTAPO_HQ: preload("res://assets/icons/poi/selected/gestapo_hq.png"),
	Enums.POIType.TOWN_HALL: preload("res://assets/icons/poi/selected/town_hall_2.png"),
	# Enums.POIType.PARK: preload("res://assets/icons/poi/selected/park.png"),
	Enums.POIType.POST_OFFICE: preload("res://assets/icons/poi/selected/post_office_2.png"),
	Enums.POIType.POLICE_STATION: preload("res://assets/icons/poi/selected/police_station_1.png"),
	Enums.POIType.TRAIN_STATION: preload("res://assets/icons/poi/selected/train_station_1.png"),
	Enums.POIType.DOCKS: preload("res://assets/icons/poi/selected/docks_1.png"),
	Enums.POIType.BROTHEL: preload("res://assets/icons/poi/selected/brothel_2.png"),
	# Enums.POIType.SUBMARINE_PEN: preload("res://assets/icons/poi/selected/submarine_pen_1.png"),
	Enums.POIType.CATHEDRAL: preload("res://assets/icons/poi/selected/cathedral_1.png"),
	Enums.POIType.CINEMA: preload("res://assets/icons/poi/selected/cinema_1.png"),
	Enums.POIType.GROCER: preload("res://assets/icons/poi/selected/grocer_1.png"),
	Enums.POIType.SHOP: preload("res://assets/icons/poi/selected/shop_2.png"),
	Enums.POIType.OFFICE: preload("res://assets/icons/poi/selected/office_2.png"),
	Enums.POIType.CHURCH: preload("res://assets/icons/poi/selected/church_1.png"),
	Enums.POIType.PUB: preload("res://assets/icons/poi/selected/pub_1.png"),
	Enums.POIType.CAFE: preload("res://assets/icons/poi/selected/cafe_1.png"),
	Enums.POIType.FACTORY: preload("res://assets/icons/poi/selected/factory_2.png"),
	Enums.POIType.WAREHOUSE: preload("res://assets/icons/poi/selected/warehouse_1.png"),
	Enums.POIType.RESIDENCE: preload("res://assets/icons/poi/selected/residence_2.png"),
	Enums.POIType.RESTAURANT: preload("res://assets/icons/poi/selected/restaurant_2.png"),
	Enums.POIType.WORKSHOP: preload("res://assets/icons/poi/selected/workshop_1.png"),
	Enums.POIType.ANTI_AIR_EMPLACEMENT: preload("res://assets/icons/poi/selected/anti_air_emplacement_1.png"),
	Enums.POIType.GESTAPO_POST: preload("res://assets/icons/poi/selected/gestapo_post_2.png"),
	Enums.POIType.AIR_BASE: preload("res://assets/icons/poi/selected/aerodrome_3.png"),
	Enums.POIType.GARRISON: preload("res://assets/icons/poi/selected/garrison_3.png"),
	Enums.POIType.AMMO_FACTORY: preload("res://assets/icons/poi/selected/ammo_factory_2.png"),
	Enums.POIType.FOUNDRY: preload("res://assets/icons/poi/selected/foundry_1.png"),
}
