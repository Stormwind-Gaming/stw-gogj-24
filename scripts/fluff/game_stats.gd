extends Node

#|==============================|
#|      Local Variables		      |
#|==============================|

var stats: Dictionary = {
	"turns": 0,
	"time": 0,
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
	EventBus.end_turn_initiated.connect(_on_end_turn)
	EventBus.stat_created.connect(_update_stat)
	EventBus.game_over.connect(_update_time)

"""
@brief Resets the stats container
"""
func reset() -> void:
	stats = stats.duplicate(true)
	for key in stats:
		if typeof(stats[key]) == TYPE_DICTIONARY:
			stats[key].success = 0
			stats[key].total = 0
		else:
			stats[key] = 0


#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Plus one turn

@param turns: int
"""
func _on_end_turn(_turn: int) -> void:
	stats.turns += 1

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

func _update_time() -> void:
	stats.time = ReferenceGetter.game_controller().time_elapsed