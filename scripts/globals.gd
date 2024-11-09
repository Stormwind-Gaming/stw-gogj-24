extends Node

var agent_card_scene = preload("res://scenes/gui/agent_card.tscn")
var radial_menu_scene = preload("res://scenes/gui/radial_menu.tscn")
var character_list_scene = preload("res://scenes/gui/character_list.tscn")
var intel_list_scene = preload("res://scenes/gui/intel_list.tscn")
var log_list_scene = preload("res://scenes/gui/log_list.tscn")
var post_radial_assignment_scene = preload("res://scenes/gui/post_radial_assignment.tscn")

var load_csvs = {
	"town_names": "res://data/town_names.csv",
	"district_names": "res://data/district_names.csv",
	"first_names": "res://data/first_names.csv",
	"last_names": "res://data/last_names.csv",
	"poi_types": "res://data/poi_types.csv",
	"poi_names": "res://data/poi_names.csv",
	"rumour_text": "res://data/rumour_text.csv"
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

#region Loaders
	_load_rumour_text(load_csvs["rumour_text"])

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
		poi_types.append({
			"poi_type": poi_type,
			"poi_name": record["poi_name"],
			"poi_description": record["poi_description"],
			"district_type": district_type,
			"spawn_chance": record["spawn_chance"],
			"max_spawn_quantity": record["max_spawn_quantity"]
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
			"type": type
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
	"BELGIAN": Enums.CharacterNationality.BELGIAN
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
	"WHO": Enums.IntelType.WHO,
	"WHAT": Enums.IntelType.WHAT,
	"WHERE": Enums.IntelType.WHERE,
	"WHEN": Enums.IntelType.WHEN
}

#endregion

#region Enum to friendly string

func get_action_type_string(action_type: Enums.ActionType) -> String:
	match action_type:
		Enums.ActionType.NONE:
			return "None"
		Enums.ActionType.ESPIONAGE:
			return "Espionage"
		Enums.ActionType.ASSASSINATION:
			return "Assassination"
		Enums.ActionType.PROPAGANDA:
			return "Propaganda"
		_:
			return "Unknown"
