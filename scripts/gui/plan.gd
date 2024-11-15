extends PanelContainer

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Label displaying the plan title
"""
@export var title_label: Label

"""
@brief Label showing the timing details of the plan
"""
@export var timing_label: RichTextLabel

"""
@brief Label showing the location details of the plan
"""
@export var location_label: RichTextLabel

"""
@brief Label showing the mission details of the plan
"""
@export var mission_label: RichTextLabel

"""
@brief Button to create the plan
"""
@export var create_plan_button: TextureButton

"""
@brief Visual indicator for completed plans
"""
@export var green_star_stamp: Control

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Whether timing text has been set
"""
var has_time_text: bool = false

"""
@brief Whether location text has been set
"""
var has_location_text: bool = false

"""
@brief Whether mission text has been set
"""
var has_mission_text: bool = false

"""
@brief Speed of the typewriter effect
"""
var type_effect_speed: float = 1.0

"""
@brief The Plan object this plan represents
"""
var plan: Plan

#|==============================|
#|          Signals            |
#|==============================|
"""
@brief Emitted when the create plan button is pressed
"""
signal create_plan

#|==============================|
#|      Setters & Getters      |
#|==============================|
"""
@brief Sets up the plan card with existing plan data.

@param plan_arg The Intel object containing plan details
"""
func set_existing_plan_card(plan_arg: Plan = null) -> void:
	plan = plan_arg
	title_label.text = plan.plan_name
	timing_label.text = plan.plan_timing
	location_label.text = plan.plan_subject_poi.poi_name
	mission_label.text = plan.plan_text
	green_star_stamp.visible = true

"""
@brief Sets up an empty plan card for new plan creation.
"""
func set_new_plan_card() -> void:
	timing_label.visible_ratio = 0
	location_label.visible_ratio = 0
	mission_label.visible_ratio = 0

"""
@brief Sets the timing text with typewriter effect.

@param text The timing text to display
"""
func set_time_text(text: String) -> void:
	# if text is the same as the previous time text, don't show it
	if timing_label.text == text:
		return
	timing_label.visible_ratio = 0
	has_time_text = true
	timing_label.text = text

"""
@brief Sets the location text with typewriter effect.

@param text The location text to display
"""
func set_location_text(text: String) -> void:
	# if text is the same as the previous location text, don't show it
	if location_label.text == text:
		return
	location_label.visible_ratio = 0
	has_location_text = true
	location_label.text = text

"""
@brief Sets the mission text with typewriter effect.

@param text The mission text to display
"""
func set_mission_text(text: String) -> void:
	# if text is the same as the previous mission text, don't show it
	if mission_label.text == text:
		return
	mission_label.visible_ratio = 0
	has_mission_text = true
	mission_label.text = text

"""
@brief Enables or disables the create plan button.

@param enabled Whether the button should be enabled
"""
func toggle_enabled_button(enabled: bool) -> void:
	create_plan_button.disabled = !enabled

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called every frame to update typewriter effects.

@param delta Time elapsed since the last frame
"""
func _process(delta: float) -> void:
	if !plan && has_time_text && timing_label.visible_ratio < 1:
		timing_label.visible_ratio += delta * type_effect_speed
	if has_location_text && location_label.visible_ratio < 1:
		location_label.visible_ratio += delta * type_effect_speed
	if has_mission_text && mission_label.visible_ratio < 1:
		mission_label.visible_ratio += delta * type_effect_speed

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the create plan button press.
Emits the create_plan signal.
"""
func _on_create_plan_btn_pressed() -> void:
	create_plan.emit()
