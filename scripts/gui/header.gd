extends Control

@onready var date = $HBoxContainer/PanelContainer2/MarginContainer/HBoxContainer/Date

func _ready():
	GameController.connect("end_turn", update_date)

func update_date(num: int) -> void:
	date.text = str(num) + " January 1942"
	
