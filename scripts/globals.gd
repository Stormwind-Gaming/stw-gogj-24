extends Node

var load_csvs = {
	"town_names": "res://data/town_names.csv",
	"district_names": "res://data/district_names.csv",
	"first_names": "res://data/first_names.csv",
	"last_names": "res://data/last_names.csv"
}

var town_names = []
var district_names = []
var first_names = []
var last_names = []

func _ready() -> void:
	for key_name in load_csvs.keys():
		var csv_data = load(load_csvs[key_name])
		var data_array = self.get(key_name)
		var col_name = key_name.substr(0, key_name.length() - 1)
		for record in csv_data.records:
			data_array.append(record[col_name])
