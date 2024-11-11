extends MarginContainer

@export var title: Label
@export var time_remaining: RichTextLabel
# @export var district_poi_details: Label
@export var agents: GridContainer

var action: Action

func set_action(action_attr: Action) -> void:
	self.action = action_attr
	title.text = Globals.action_type_to_string(action.action_type)
	time_remaining.bbcode_text = "[b]Time remaining:[/b] " + '1' + " days" #str(action.time_remaining)

	# for each agent in the action's agents list
	for agent in action.characters:
		# Instance the agent card scene
		var agent_card = Globals.mini_agent_card_scene.instantiate()
		agent_card.set_character(agent.id)
		
		# Add the instance to the scene tree
		agents.add_child(agent_card)
