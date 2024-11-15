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
	
	# Set the title text
	title.text = "%s - %s" % [Globals.get_action_type_string(action.action_type), type]
	
	# Set the time remaining text
	time_remaining.bbcode_text = "[b]Time remaining:[/b] " + '1' + " days" #str(action.time_remaining)

	# Create and add agent cards for each character in the action
	for agent in action.characters:
		var agent_card = Globals.mini_agent_card_scene.instantiate()
		agent_card.set_character(agent)
		agents.add_child(agent_card)
	
	# Handle remove button state based on plan association
	if not action.associated_plan:
		# Enable remove button for standalone actions
		remove_button.disabled = false
	else:
		# For plan actions, check if plan is in progress
		if action.associated_plan.plan_in_progress:
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
	print("Remove button pressed")
	# Remove the action and let it clean up
	action.queue_free()
	# Remove this UI element
	queue_free()
