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

#|==============================|
#|      Lifecycle Methods       |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Sets up signals to listen for changes
"""
func _ready() -> void:
	EventBus.end_turn_complete.connect(_check_milestones)
	
"""
@brief Checks if any milestones have been passed
"""
func _check_milestones(_num: int) -> void:
	# check if any global milestones have been passed
	var global_heat = GameController.get_heat_level()

	if not global_heat_breakpoint_medium and global_heat >= 35:
		global_heat_breakpoint_medium = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.HEAT_BREAKPOINT_MEDIUM, [] as Array[Character], null)
	if not global_heat_breakpoint_high and global_heat >= 70:
		global_heat_breakpoint_high = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.HEAT_BREAKPOINT_HIGH, [] as Array[Character], null)

	var global_sympathy = GameController.get_resistance_level()

	if not global_sympathy_breakpoint_low and global_sympathy >= 30:
		global_sympathy_breakpoint_low = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_LOW, [] as Array[Character], null)
	if not global_sympathy_breakpoint_medium and global_sympathy >= 45:
		global_sympathy_breakpoint_medium = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_MEDIUM, [] as Array[Character], null)
	if not global_sympathy_breakpoint_high and global_sympathy >= 60:
		global_sympathy_breakpoint_high = true
		EventBus.create_new_event_panel.emit(Enums.EventOutcomeType.SYMPATHY_BREAKPOINT_HIGH, [] as Array[Character], null)
	
	# TODO: This needs to be slightly more robust because players can also get agents from plans
	if global_sympathy_breakpoint_high:
		GameController.max_agents = 5
	elif global_sympathy_breakpoint_medium:
		GameController.max_agents = 4
	elif global_sympathy_breakpoint_low:
		GameController.max_agents = 3
	else:
		GameController.max_agents = 2