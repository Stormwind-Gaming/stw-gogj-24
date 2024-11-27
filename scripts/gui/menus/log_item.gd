extends MarginContainer

@export var log_type: Enums.LogType
@export var log_message: String

@onready var log_type_texture_rect = find_child("TextureRect")
@onready var log_message_label = find_child("Label")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match log_type:
		Enums.LogType.WORLD_INFO:
			log_type_texture_rect.texture = load("res://assets/icons/logs/world_info.png")
		Enums.LogType.ACTION_INFO:
			log_type_texture_rect.texture = load("res://assets/icons/logs/action_info.png")
		Enums.LogType.CONSEQUENCE:
			log_type_texture_rect.texture = load("res://assets/icons/logs/consequence.png")
			self.add_theme_constant_override("margin_left", 40)
		Enums.LogType.SUCCESS:
			log_type_texture_rect.texture = load("res://assets/icons/logs/success.png")
			self.add_theme_constant_override("margin_left", 40)
		Enums.LogType.WORLD_EVENT:
			log_type_texture_rect.texture = load("res://assets/icons/logs/world_event.png")
	log_message_label.text = log_message
