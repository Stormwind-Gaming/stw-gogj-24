extends ControlWithCleanup

#|==============================|
#|   Exported Properties       |
#|==============================|
"""
@brief TextureRect for endgame image
"""
@export var endgame_image: TextureRect

"""
@brief RichTextLabel for endgame text
"""
@export var endgame_text: RichTextLabel

"""
@brief TextureRect for background colour
"""
@export var background_colour: TextureRect

"""
@brief TextureRect for fade colour
"""
@export var fade_colour: TextureRect

"""
@brief Label turns
"""
@export var turns: Label

"""
@brief Label time
"""
@export var time: Label

"""
@brief Label missions
"""

@export var missions: Label

"""
@brief Label subtlety
"""
@export var subtlety: Label

"""
@brief Label smarts
"""
@export var smarts: Label

"""
@brief Label charm
"""
@export var charm: Label

"""
@brief Label Espionage
"""
@export var espionage: Label

"""
@brief Label Surveillance
"""
@export var surveillance: Label

"""
@brief Label Propaganda
"""
@export var propaganda: Label

"""
@brief Label MIA
"""
@export var mia: Label

"""
@brief Label Injured
"""
@export var injured: Label

"""
@brief Label Dead
"""
@export var dead: Label

"""
@brief GridContainer escaped sympathisers
"""
@export var escaped_sympathisers: GridContainer

"""
@brief GridContainer left behind sympathisers
"""
@export var left_behind_sympathisers: GridContainer

"""
@brief Escaped label
"""
@export var escaped_label: Label



#|==============================|
#|        Local Variables      |
#|==============================|

var win_endgame_colour: Color = Color(0.929, 0.851, 0.714)
var lose_endgame_colour: Color = Color.BLACK

#|==============================|
#|        Lifecycle methods     |
#|==============================|
"""
@brief Called when the node enters the scene tree for the first time
"""
func _ready() -> void:
	EventBus.close_all_windows_and_event_panels.emit()
	if GlobalMilestones.endgame_end_type != Enums.EventOutcomeType.NONE and GlobalMilestones.endgame_end_type != Enums.EventOutcomeType.GAME_OVER:
		update_gui()
		$AnimationPlayer.play("fade_in_endgame")
	else:
		$AnimationPlayer.play("fade_in_game_over")


#|==============================|
#|        Signal Callbacks      |
#|==============================|
"""
@brief Called when the quit to menu button is pressed
"""
func _on_quit_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
	

#|==============================|
#|          Methods             |
#|==============================|
"""
@brief Updates the GUI to reflect new game state.
"""
func update_gui() -> void:
	# get endgame type
	var endgame_type: Enums.EventOutcomeType = GlobalMilestones.endgame_end_type
	# set endgame text for this type
	endgame_text.text = Globals.get_endgame_text(endgame_type).replace("{town}", ReferenceGetter.game_controller().town_details.town_name)
	# set endgame image for this type
	endgame_image.texture = Globals.endgame_page_images[endgame_type]

	# set colours for win/lose
	var win: bool = true
	match endgame_type:
		Enums.EventOutcomeType.HEAT_TRAIN_FAILURE:
			win = false
		Enums.EventOutcomeType.HEAT_PORT_FAILURE:
			win = false
		Enums.EventOutcomeType.RESISTANCE_AIRFIELD_FAILURE:
			win = false
		Enums.EventOutcomeType.RESISTANCE_GENERAL_FAILURE:
			win = false
		_:
			pass
	
	if not win:
		background_colour.texture.gradient.set_color(0, lose_endgame_colour)
		fade_colour.texture.gradient.set_color(0, lose_endgame_colour)
		self.theme = Globals.dark_theme
		escaped_label.text = "Captured"


	turns.text = str(GameStats.stats.turns)
	missions.text = "%s/%s" % [str(GameStats.stats.missions.success), str(GameStats.stats.missions.total)]
	subtlety.text = "%s/%s" % [str(GameStats.stats.subtlety.success), str(GameStats.stats.subtlety.total)]
	smarts.text = "%s/%s" % [str(GameStats.stats.smarts.success), str(GameStats.stats.smarts.total)]
	charm.text = "%s/%s" % [str(GameStats.stats.charm.success), str(GameStats.stats.charm.total)]
	espionage.text = "%s/%s" % [str(GameStats.stats.espionage.success), str(GameStats.stats.espionage.total)]
	surveillance.text = "%s/%s" % [str(GameStats.stats.surveillance.success), str(GameStats.stats.surveillance.total)]
	propaganda.text = "%s/%s" % [str(GameStats.stats.propaganda.success), str(GameStats.stats.propaganda.total)]
	mia.text = str(GameStats.stats.mia)
	injured.text = str(GameStats.stats.injured)
	dead.text = str(GameStats.stats.dead)

	for child in escaped_sympathisers.get_children():
		child.queue_free()
	for child in left_behind_sympathisers.get_children():
		child.queue_free()

	var sympathisers = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_SYMPATHISER_NOT_RECRUITED) + ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_SYMPATHISER_RECRUITED)
	for sympathiser in sympathisers:
		var mini_agent_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_scene.set_character(sympathiser)
		escaped_sympathisers.add_child(mini_agent_scene)
	
	var other_sympathisers = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_MIA) + ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_DECEASED)
	for sympathiser in other_sympathisers:
		var mini_agent_scene = Globals.mini_agent_card_scene.instantiate()
		mini_agent_scene.set_character(sympathiser)
		left_behind_sympathisers.add_child(mini_agent_scene)
