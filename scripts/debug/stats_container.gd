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
#|      Local Variables		      |
#|==============================|

var stats: Dictionary = {
	"turns": 0,
	"missions": {
		"total": 0,
		"success": 0
	},
	"subtlety": {
		"total": 0,
		"success": 0
	},
	"smarts": {
		"total": 0,
		"success": 0
	},
	"charm": {
		"total": 0,
		"success": 0
	},
	"espionage": {
		"total": 0,
		"success": 0
	},
	"surveillance": {
		"total": 0,
		"success": 0
	},
	"propaganda": {
		"total": 0,
		"success": 0
	},
	"mia": 0,
	"injured": 0,
	"dead": 0
}


#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.

Connects signals and initializes UI elements.
"""
func _ready():
	EventBus.end_turn_complete.connect(_update_gui)
	EventBus.stat_created.connect(_update_stat)
	_update_gui(0)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Updates the GUI to reflect new game state.
"""

func _update_gui(i: int):
	stats.turns = i + 1
	turns.text = str(stats.turns)
	missions.text = "%s/%s" % [str(stats.missions.success), str(stats.missions.total)]
	subtlety.text = "%s/%s" % [str(stats.subtlety.success), str(stats.subtlety.total)]
	smarts.text = "%s/%s" % [str(stats.smarts.success), str(stats.smarts.total)]
	charm.text = "%s/%s" % [str(stats.charm.success), str(stats.charm.total)]
	espionage.text = "%s/%s" % [str(stats.espionage.success), str(stats.espionage.total)]
	surveillance.text = "%s/%s" % [str(stats.surveillance.success), str(stats.surveillance.total)]
	propaganda.text = "%s/%s" % [str(stats.propaganda.success), str(stats.propaganda.total)]
	mia.text = str(stats.mia)
	injured.text = str(stats.injured)
	dead.text = str(stats.dead)

"""
@brief Update stats
"""
func _update_stat(stat: String, success: bool = false) -> void:
	match stat:
		"missions":
			stats.missions.total += 1
			if success:
				stats.missions.success += 1
		"subtlety":
			stats.subtlety.total += 1
			if success:
				stats.subtlety.success += 1
		"smarts":
			stats.smarts.total += 1
			if success:
				stats.smarts.success += 1
		"charm":
			stats.charm.total += 1
			if success:
				stats.charm.success += 1
		"espionage":
			stats.espionage.total += 1
			if success:
				stats.espionage.success += 1
		"surveillance":
			stats.surveillance.total += 1
			if success:
				stats.surveillance.success += 1
		"propaganda":
			stats.propaganda.total += 1
			if success:
				stats.propaganda.success += 1
		"mia":
			stats.mia += 1
		"injured":
			stats.injured += 1
		"dead":
			stats.dead += 1
		_:
			pass
