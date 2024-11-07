extends PanelContainer

var character_id: String
var character_name: String

func _ready():
	$MarginContainer/VBoxContainer/Label.text = character_name
