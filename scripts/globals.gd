extends Node

var agent_card_scene = preload("res://scenes/gui/agent_card.tscn")
var radial_menu_scene = preload("res://scenes/gui/radial_menu.tscn")

var load_csvs = {
	"town_names": "res://data/town_names.csv",
	"district_names": "res://data/district_names.csv",
	"first_names": "res://data/first_names.csv",
	"last_names": "res://data/last_names.csv",
}

var town_names = []
var district_names = []
var first_names = []
var last_names = []

func _ready() -> void:
	_load_town_names(load_csvs["town_names"])
	_load_district_names(load_csvs["district_names"])
	_load_first_names(load_csvs["first_names"])
	_load_last_names(load_csvs["last_names"])

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

#region EnumMaps

var gender_map = {
	"MALE": Enums.CharacterGender.MALE,
	"FEMALE": Enums.CharacterGender.FEMALE
}

var nationality_map = {
	"GERMAN": Enums.CharacterNationality.GERMAN,
	"BELGIAN": Enums.CharacterNationality.BELGIAN
}

#endregion