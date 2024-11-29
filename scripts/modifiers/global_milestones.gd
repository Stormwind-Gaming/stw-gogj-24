extends Node

#|==============================|
#|    Milestones passed         |
#|==============================|
"""
@brief Values holding whether the milestone has been passed
"""

var global_heat_breakpoint_low: bool = true # 0
var global_heat_breakpoint_medium: bool = false # 35
var global_heat_breakpoint_high: bool = false # 70

var global_sympathy_breakpoint_low: bool = false # 30
var global_sympathy_breakpoint_medium: bool = false # 45
var global_sympathy_breakpoint_high: bool = false # 60

var endgame_end_type: Enums.EventOutcomeType = Enums.EventOutcomeType.NONE

#|==============================|
#|      Lifecycle Methods       |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Sets up signals to listen for changes
"""
func _ready() -> void:
	LogDuck.d("Initializing global milestones system")
	EventBus.end_turn_complete.connect(_check_milestones)
	
"""
@brief Checks if any milestones have been passed
"""
func _check_milestones(_num: int) -> void:
	var global_heat = ReferenceGetter.game_controller().get_heat_level()
	var global_sympathy = ReferenceGetter.game_controller().get_resistance_level()
	
	LogDuck.d("Checking global milestones", {
		"heat": global_heat,
		"sympathy": global_sympathy,
		"current_max_agents": ReferenceGetter.game_controller().max_agents
	})

	# Check heat milestones
	if not global_heat_breakpoint_medium and global_heat >= Constants.GLOBAL_HEAT_BREAKPOINT_MEDIUM:
		LogDuck.d("Heat breakpoint medium reached", {
			"heat_level": global_heat,
			"threshold": Constants.GLOBAL_HEAT_BREAKPOINT_MEDIUM
		})
		global_heat_breakpoint_medium = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.HEAT_BREAKPOINT_MEDIUM, [] as Array[Character], null)
	
	if not global_heat_breakpoint_high and global_heat >= Constants.GLOBAL_HEAT_BREAKPOINT_HIGH:
		LogDuck.d("Heat breakpoint high reached", {
			"heat_level": global_heat,
			"threshold": Constants.GLOBAL_HEAT_BREAKPOINT_HIGH
		})
		global_heat_breakpoint_high = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.HEAT_BREAKPOINT_HIGH, [] as Array[Character], null)

	# Check sympathy milestones
	if not global_sympathy_breakpoint_low and global_sympathy >= Constants.GLOBAL_SYMPATHY_BREAKPOINT_LOW:
		LogDuck.d("Sympathy breakpoint low reached", {
			"sympathy_level": global_sympathy,
			"threshold": Constants.GLOBAL_SYMPATHY_BREAKPOINT_LOW
		})
		global_sympathy_breakpoint_low = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_LOW, [] as Array[Character], null)
	
	if not global_sympathy_breakpoint_medium and global_sympathy >= Constants.GLOBAL_SYMPATHY_BREAKPOINT_MEDIUM:
		LogDuck.d("Sympathy breakpoint medium reached", {
			"sympathy_level": global_sympathy,
			"threshold": Constants.GLOBAL_SYMPATHY_BREAKPOINT_MEDIUM
		})
		global_sympathy_breakpoint_medium = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_MEDIUM, [] as Array[Character], null)
	
	if not global_sympathy_breakpoint_high and global_sympathy >= Constants.GLOBAL_SYMPATHY_BREAKPOINT_HIGH:
		LogDuck.d("Sympathy breakpoint high reached", {
			"sympathy_level": global_sympathy,
			"threshold": Constants.GLOBAL_SYMPATHY_BREAKPOINT_HIGH
		})
		global_sympathy_breakpoint_high = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_HIGH, [] as Array[Character], null)

	# Update max agents based on sympathy level
	var previous_max_agents = ReferenceGetter.game_controller().max_agents
	if global_sympathy_breakpoint_high:
		ReferenceGetter.game_controller().max_agents = 5 + ReferenceGetter.game_controller().agent_modifier
	elif global_sympathy_breakpoint_medium:
		ReferenceGetter.game_controller().max_agents = 4 + ReferenceGetter.game_controller().agent_modifier	
	elif global_sympathy_breakpoint_low:
		ReferenceGetter.game_controller().max_agents = 3 + ReferenceGetter.game_controller().agent_modifier	
	else:
		ReferenceGetter.game_controller().max_agents = 2 + ReferenceGetter.game_controller().agent_modifier
		
	if previous_max_agents != ReferenceGetter.game_controller().max_agents:
		LogDuck.d("Max agents updated", {
			"previous": previous_max_agents,
			"new": ReferenceGetter.game_controller().max_agents,
			"sympathy_level": global_sympathy
		})

#|==============================|
#|      Public Methods          |
#|==============================|
"""
@brief Resets the global milestones
"""
func reset() -> void:
	global_heat_breakpoint_low = true
	global_heat_breakpoint_medium = false
	global_heat_breakpoint_high = false

	global_sympathy_breakpoint_low = false
	global_sympathy_breakpoint_medium = false
	global_sympathy_breakpoint_high = false

	endgame_end_type = Enums.EventOutcomeType.NONE