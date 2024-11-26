extends PanelContainer

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Label turns
"""
@export var turns: Label

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



#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.

Connects signals and initializes UI elements.
"""
func _ready():
	EventBus.end_turn_complete.connect(_update_gui)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Updates the GUI to reflect new game state.
"""
func _update_gui(_i: int):
	turns.text = str(GameStats.GameStats.stats.turns)
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
