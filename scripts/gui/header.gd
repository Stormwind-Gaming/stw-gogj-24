extends Control

@export var date: Label
@export var heat_bar: ProgressBar
@export var resistance_bar: ProgressBar

func _ready():
	GameController.connect("end_turn_complete", update_gui)
	GameController.connect("new_district_registered", update_gui)
	resistance_bar.value = GameController.get_resistance_level()
	heat_bar.value = GameController.get_heat_level()
	date.text = GameController.calendar.get_date_string()

func update_gui() -> void:
	date.text = GameController.calendar.get_date_string()
	resistance_bar.value = GameController.get_resistance_level()
	heat_bar.value = GameController.get_heat_level()

	
