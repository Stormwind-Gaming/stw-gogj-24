extends Window

@export var label: RichTextLabel
var type_effect: bool = false
var type_effect_speed: float = 0.25

func _ready():
	# Connect the close_requested signal
	connect("close_requested", Callable(self, "_on_close_requested"))
	
	for line in GameController.get_turn_log(GameController.turn_number):
		label.text += line + "\n"

func is_end_turn_log(type_effect_speed: float = 0.25) -> bool:
	type_effect = true
	label.visible_ratio = 0
	self.type_effect_speed = type_effect_speed
	return type_effect

func _process(delta: float) -> void:
	if type_effect:
		label.visible_ratio += delta * type_effect_speed
		if label.visible_ratio >= 1:
			type_effect = false


func _on_close_button_pressed() -> void:
	queue_free()
