extends PanelContainer

@export var title_label: Label
@export var timing_label: RichTextLabel
@export var location_label: RichTextLabel
@export var mission_label: RichTextLabel
@export var create_plan_button: TextureButton
@export var green_star_stamp: Control

var has_time_text: bool = false
var has_location_text: bool = false
var has_mission_text: bool = false

var type_effect_speed: float = 1.0

var plan: Intel

signal create_plan

func set_existing_plan_card(plan_arg: Intel = null) -> void:
	plan = plan_arg
	title_label.text = plan_arg.plan_name
	timing_label.text = plan.plan_when
	location_label.text = plan.plan_where
	mission_label.text = plan.plan_who_what
	green_star_stamp.visible = true

func set_new_plan_card() -> void:
	timing_label.visible_ratio = 0
	location_label.visible_ratio = 0
	mission_label.visible_ratio = 0

func _process(delta: float) -> void:
	if !plan && has_time_text && timing_label.visible_ratio < 1:
		timing_label.visible_ratio += delta * type_effect_speed
	if has_location_text && location_label.visible_ratio < 1:
		location_label.visible_ratio += delta * type_effect_speed
	if has_mission_text && mission_label.visible_ratio < 1:
		mission_label.visible_ratio += delta * type_effect_speed

func set_time_text(text: String) -> void:
	# if text is the same as the previous time text, don't show it
	if timing_label.text == text:
		return
	timing_label.visible_ratio = 0
	has_time_text = true
	timing_label.text = text

func set_location_text(text: String) -> void:
	# if text is the same as the previous location text, don't show it
	if location_label.text == text:
		return
	location_label.visible_ratio = 0
	has_location_text = true
	location_label.text = text

func set_mission_text(text: String) -> void:
	# if text is the same as the previous mission text, don't show it
	if mission_label.text == text:
		return
	mission_label.visible_ratio = 0
	has_mission_text = true
	mission_label.text = text

func toggle_enabled_button(enabled: bool) -> void:
	create_plan_button.disabled = !enabled

func _on_create_plan_btn_pressed() -> void:
	create_plan.emit()
