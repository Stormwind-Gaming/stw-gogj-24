extends Control

func set_town_name(town_name) -> void:
	$MarginContainer/LeftVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TownName.text = "Town Name: " + town_name

func add_character_card(character_id: String) -> void:
	# get character from store
	var local_character = GlobalRegistry.get_object(GlobalRegistry.Registry_Category.CHARACTER, character_id)
	var agent_card = Globals.agent_card_scene.instantiate()
	agent_card.character_id = character_id
	agent_card.character_name = local_character.get_full_name()
	$MarginContainer/LeftVBoxContainer/PanelContainer2/MarginContainer/GridContainer.add_child(agent_card)
	
