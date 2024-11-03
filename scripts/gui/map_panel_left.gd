extends Control

func set_town_name(town_name) -> void:
	$MarginContainer/LeftVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TownName.text = "Town Name: " + town_name
