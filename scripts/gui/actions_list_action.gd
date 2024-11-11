extends MarginContainer

@export var remove_button: TextureButton
@export var title: Label
@export var time_remaining: RichTextLabel
# @export var district_poi_details: Label
@export var agents: GridContainer

var action: Action

signal remove_action

func set_action(action_attr: Action) -> void:
	self.action = action_attr
	var type = ''
	if action_attr.associated_plan:
		type = 'Plan'
	else:
		type = 'Action'
	title.text = "%s - %s" % [Globals.get_action_type_string(action.action_type), type]
	time_remaining.bbcode_text = "[b]Time remaining:[/b] " + '1' + " days" #str(action.time_remaining)

	# for each agent in the action's agents list
	for agent in action.characters:
		# Instance the agent card scene
		var agent_card = Globals.mini_agent_card_scene.instantiate()
		agent_card.set_character(agent.id)
		
		# Add the instance to the scene tree
		agents.add_child(agent_card)
	
	if not action.associated_plan:
		# if there is no plan associated with the action, enable the remove button
		remove_button.disabled = false
	else:
		# if there is a plan associated with the action, check if the plan is already in progress
		if action.associated_plan.plan_in_progress:
			# if the plan is in progress, disable the remove button
			remove_button.disabled = true
		else:
			# if the plan is not in progress, enable the remove button
			remove_button.disabled = false

func _on_remove_button_pressed() -> void:
	print("Remove button pressed")
	GameController.remove_action(action)
	emit_signal("remove_action", action)
	queue_free()
