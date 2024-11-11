extends AtlasTexture
class_name RadialOption

@export var radial_option_name := ''
var action_type: Enums.ActionType
 
func _init(type: Enums.ActionType) -> void:
	var atlas_path = "res://assets/sprites/radial_menu_icons.png"
	var region = Rect2(0, 0, 64, 64)
	match type:
		Enums.ActionType.NONE:
			radial_option_name = "Close"
			region = Rect2(0, 0, 64, 64)
		Enums.ActionType.INFO:
			radial_option_name = "Info"
			region = Rect2(256, 0, 64, 64)
		Enums.ActionType.ESPIONAGE:
			radial_option_name = "Espionage"
			region = Rect2(64, 0, 64, 64)
		Enums.ActionType.SURVEILLANCE:
			radial_option_name = "Surveillance"
			region = Rect2(128, 0, 64, 64)
		Enums.ActionType.PROPAGANDA:
			radial_option_name = "Sabotage"
			region = Rect2(192, 0, 64, 64)
	
	var texture = load(atlas_path)
	self.atlas = texture
	self.region = region
	self.action_type = type
