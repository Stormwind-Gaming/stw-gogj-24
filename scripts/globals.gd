extends Node

var confirmation_dialog_scene = preload("res://scenes/gui/confirmation_dialog.tscn")
var agent_card_scene = preload("res://scenes/gui/agent_card.tscn")
var mini_agent_card_scene = preload("res://scenes/gui/mini_agent_card.tscn")
var radial_menu_scene = preload("res://scenes/gui/radial_menu.tscn")
var character_list_scene = preload("res://scenes/gui/character_list.tscn")
var intel_list_scene = preload("res://scenes/gui/intel_list.tscn")
var log_list_scene = preload("res://scenes/gui/log_list.tscn")
var actions_list_scene = preload("res://scenes/gui/actions_list.tscn")
var post_radial_assignment_scene = preload("res://scenes/gui/post_radial_assignment.tscn")
var actions_list_action_scene = preload("res://scenes/gui/actions_list_action.tscn")
var plan_scene = preload("res://scenes/gui/plan.tscn")

var load_csvs = {
	"town_names": "res://data/town_names.csv",
	"district_names": "res://data/district_names.csv",
	"first_names": "res://data/first_names.csv",
	"last_names": "res://data/last_names.csv",
	"poi_types": "res://data/poi_types.csv",
	"poi_names": "res://data/poi_names.csv",
	"rumour_text": "res://data/rumour_text.csv",
	"items": "res://data/items.csv"
}

var town_names = []
var district_names = []
var first_names = []
var last_names = []
var poi_types = []
var poi_names = []
var rumour_text = []

func _ready() -> void:
	_load_town_names(load_csvs["town_names"])
	_load_district_names(load_csvs["district_names"])
	_load_first_names(load_csvs["first_names"])
	_load_last_names(load_csvs["last_names"])
	_load_poi_types(load_csvs["poi_types"])
	_load_poi_names(load_csvs["poi_names"])
	_load_rumour_text(load_csvs["rumour_text"])

#region Loaders

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
		var poi_type = poi_type_map[record["poi_name"].to_upper()]
		var district_type = district_type_map[record["district_type"].to_upper()]
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
		})
	
func _load_poi_names(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		var poi_type = poi_type_map[record["poi_type"].to_upper()]
		poi_names.append({
			"poi_type": poi_type,
			"poi_name": record["poi_name"],
		})

#endregion

#region getters
func _load_rumour_text(path: String) -> void:
	var csv_data = load(path)
	for record in csv_data.records:
		var type = rumour_map[record["type"].to_upper()]
		rumour_text.append({
			"text": record["text"],
			"type": type,
			"effect": intel_effect_map[record['effect'].to_upper()],
			"subject": record['subject'],
		})

func get_rumour_text(type: Enums.IntelType) -> Dictionary:
	var filtered_rumour_text = rumour_text.filter(
		func(record):
			return record.type == type
	)
	return filtered_rumour_text[randi() % filtered_rumour_text.size()]

func get_new_town_name() -> String:
	return town_names[randi() % town_names.size()]

func get_new_district_name() -> String:
	return district_names[randi() % district_names.size()]

func get_new_first_name(gender: Enums.CharacterGender, nationality: Enums.CharacterNationality) -> Dictionary:
	var filtered_first_names = first_names.filter(
		func(first_name):
			return first_name != null and first_name.gender == gender and first_name.nationality == nationality
	)
	return filtered_first_names[randi() % filtered_first_names.size()]

func get_all_first_names(gender: Enums.CharacterGender, nationality: Enums.CharacterNationality) -> Array:
	return first_names.filter(
		func(first_name):
			return first_name != null and first_name.gender == gender and first_name.nationality == nationality
	)

func get_new_last_name(nationality: Enums.CharacterNationality) -> Dictionary:
	var filtered_last_names = last_names.filter(
		func(last_name):
			return last_name != null and last_name.nationality == nationality
	)
	return filtered_last_names[randi() % filtered_last_names.size()]

func get_all_last_names(nationality: Enums.CharacterNationality) -> Array:
	return last_names.filter(
		func(last_name):
			return last_name != null and last_name.nationality == nationality
	)

func get_poi_types(district: Enums.DistrictType) -> Array:
	return poi_types.filter(
		func(poi_type):
			return poi_type != null and poi_type.district_type == district
	)

func get_poi_name(poi_type: Enums.POIType) -> String:
	var filtered_poi_names = poi_names.filter(
		func(poi_name):
			return poi_name != null and poi_name.poi_type == poi_type
	)
	return filtered_poi_names[randi() % filtered_poi_names.size()]["poi_name"]

func get_all_poi_names(poi_type: Enums.POIType) -> Array:
	return poi_names.filter(
		func(poi_name):
			return poi_name != null and poi_name.poi_type == poi_type
	)

#endregion

#region EnumMaps

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
	"CATHEDRAL": Enums.POIType.CATHEDRAL
}

var district_type_map = {
	"SHOPPING": Enums.DistrictType.SHOPPING,
	"INDUSTRIAL": Enums.DistrictType.INDUSTRIAL,
	"RESIDENTIAL": Enums.DistrictType.RESIDENTIAL
}

var rumour_map = {
	"WHOWHAT": Enums.IntelType.WHOWHAT,
	"WHERE": Enums.IntelType.WHERE,
	"WHEN": Enums.IntelType.WHEN
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

#endregion

#region Enum to friendly string

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

func get_intel_effect_string(effects, bbcode_enabled: bool = false) -> String:
	var effect = effects[0]

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
			return "Duration: 4 Days, Expiry: 1 Day"
		Enums.IntelEffect.D_FOUR_E_TWO:
			return "Duration: 4 Days, Expiry: 2 Days"
		Enums.IntelEffect.D_FOUR_E_THREE:
			return "Duration: 4 Days, Expiry: 3 Days"
		Enums.IntelEffect.D_FOUR_E_FOUR:
			return "Duration: 4 Days, Expiry: 4 Days"
		Enums.IntelEffect.NONE:
			return "None"
		_:
			return "Unknown"

func get_character_status_string(status: Enums.CharacterStatus) -> String:
	match status:
		Enums.CharacterStatus.NONE:
			return "None"
		Enums.CharacterStatus.SYMPATHISER:
			return "Sympathiser"
		Enums.CharacterStatus.AVAILABLE:
			return "Available"
		Enums.CharacterStatus.ASSIGNED:
			return "Assigned"
		Enums.CharacterStatus.MIA:
			return "MIA"
		Enums.CharacterStatus.INCARCERATED:
			return "Incarcerated"
		Enums.CharacterStatus.DECEASED:
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
		Enums.DistrictType.SHOPPING:
			return "Shopping"
		Enums.DistrictType.INDUSTRIAL:
			return "Industrial"
		Enums.DistrictType.RESIDENTIAL:
			return "Residential"
		_:
			return "Unknown"

#endregion


#region Preload Profile Images

var profile_images = {
	Enums.CharacterNationality.GERMAN: {
		Enums.CharacterGender.MALE: [
			preload("res://assets/profile_pictures/german/male/german-male-1.png"),
			preload("res://assets/profile_pictures/german/male/german-male-2.png"),
			preload("res://assets/profile_pictures/german/male/german-male-3.png"),
		],
		Enums.CharacterGender.FEMALE: [
			preload("res://assets/profile_pictures/german/female/german-female-1.png"),
		]
	},
	Enums.CharacterNationality.BELGIAN: {
		Enums.CharacterGender.MALE: [
			preload("res://assets/profile_pictures/belgian/male/belgian-male-1.png"),
			preload("res://assets/profile_pictures/belgian/male/belgian-male-2.png"),
		],
		Enums.CharacterGender.FEMALE: [
			preload("res://assets/profile_pictures/belgian/female/belgian-female-1.png"),
		]
	},
	Enums.CharacterNationality.FRENCH: {
		Enums.CharacterGender.MALE: [
			preload("res://assets/profile_pictures/french/male/blank.png"),
		],
		Enums.CharacterGender.FEMALE: [
			preload("res://assets/profile_pictures/french/female/blank.png"),
		]
	},
	Enums.CharacterNationality.BRITISH: {
		Enums.CharacterGender.MALE: [
			preload("res://assets/profile_pictures/british/male/blank.png"),
		],
		Enums.CharacterGender.FEMALE: [
			preload("res://assets/profile_pictures/british/female/blank.png"),
		]
	},
}

#endreigon
