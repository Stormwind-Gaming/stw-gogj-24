extends Node

var agent_card_scene = preload("res://scenes/gui/agent_card.tscn")

var load_csvs = {
	"town_names": "res://data/town_names.csv",
	"district_names": "res://data/district_names.csv",
	"belgian_male_first_names": "res://data/belgian_male_first_names.csv",
	"belgian_female_first_names": "res://data/belgian_female_first_names.csv",
	"belgian_last_names": "res://data/belgian_last_names.csv",
	"german_male_first_names": "res://data/german_male_first_names.csv",
	"german_female_first_names": "res://data/german_female_first_names.csv",
	"german_last_names": "res://data/german_last_names.csv",
}

var town_names = []
var district_names = []
var belgian_male_first_names = []
var belgian_female_first_names = []
var belgian_last_names = []
var german_male_first_names = []
var german_female_first_names = []
var german_last_names = []

func _ready() -> void:
	for key_name in load_csvs.keys():
		var csv_data = load(load_csvs[key_name])
		var data_array = self.get(key_name)
		var col_name = key_name.substr(0, key_name.length() - 1)
		for record in csv_data.records:
			data_array.append(record[col_name])
