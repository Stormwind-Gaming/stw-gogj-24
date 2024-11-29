extends MarginContainer

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Button to remove this action from the list
"""
@export var remove_button: TextureButton

"""
@brief Label displaying the action title
"""
@export var title: Label

"""
@brief Label displaying the location of the action
"""
@export var location_label: RichTextLabel

"""
@brief Label displaying the skill required for the action
"""
@export var skill_label: RichTextLabel

"""
@brief Label showing the remaining time for this action
"""
@export var time_remaining: RichTextLabel

"""
@brief Grid container for displaying agent cards
"""
@export var agents: GridContainer

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief The action this UI element represents
"""
var action: BaseAction

#|==============================|
#|          Signals            |
#|==============================|
"""
@brief Emitted when the action is removed from the list
"""
signal remove_action

#|==============================|
#|      Setters & Getters      |
#|==============================|
"""
@brief Sets up the UI elements for this action.

@param action_attr The action to display in this list item
"""
func set_action(action_attr: BaseAction) -> void:
	self.action = action_attr
	
	# Determine if this is a plan or standalone action
	var type = ''
	if action_attr.associated_plan:
		type = 'Plan'
	else:
		type = 'Action'
	
	var main_title = ''
	if action_attr.associated_plan:
		main_title = action_attr.associated_plan.plan_name
	else:
		main_title = Globals.get_action_type_string(action.action_type)

	# Set the title text
	title.text = "%s - %s" % [main_title, type]
	
	# Set the time remaining text
	time_remaining.bbcode_text = "Time remaining: " + str(action.turn_to_end - ReferenceGetter.game_controller().turn_number) + " days"

	# set the District and PoI
	var location_text = ''
	var poi = action.poi
	var district = poi.parent_district
	if district:
		location_text = "District: %s - %s\n" % [district.district_name, Globals.get_district_type_string(district.district_type)]
	if poi:
		location_text += "POI: %s" % poi.poi_name
	location_label.text = location_text

	# Set the skill required text
	skill_label.text = "Skill required: %s" % Globals.get_stat_string(action.poi.stat_check_type)

	# Create and add agent cards for each character in the action
	for agent in action.characters:
		var agent_card = Globals.mini_agent_card_scene.instantiate()
		agent_card.set_character(agent)
		agents.add_child(agent_card)
	
	# Check if the action is in flight
	if action.in_flight:
		remove_button.disabled = true
	else:
		remove_button.disabled = false

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the remove button press event.
Removes the action from the game and emits the remove_action signal.
"""
func _on_remove_button_pressed() -> void:
	var confimation_dialog = Globals.confirmation_dialog_scene.instantiate()
	confimation_dialog.setup_dialog("Are you sure you want to remove this action?", "Remove", "Cancel")
	confimation_dialog.on_confirmed.connect(_on_remove_confirmed)
	add_child(confimation_dialog)

"""
@brief Handles the remove action confirmation event.
Removes the action from the game and cleans up the UI elements.
"""
func _on_remove_confirmed() -> void:
	# Remove the action and let it clean up
	action.queue_free()
	# Remove this UI element
	queue_free()
