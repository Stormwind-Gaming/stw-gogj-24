extends Control

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Label displaying the current date
"""
@export var date: Label

"""
@brief Progress bar showing the current heat level
"""
@export var heat_bar: ProgressBar

"""
@brief Progress bar showing the current resistance level
"""
@export var resistance_bar: ProgressBar

"""
@brief Container for agent cards
"""
@export var agents_wrapper: VBoxContainer

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Connects signals and initializes UI elements.
"""
func _ready():
	GameController.connect("end_turn_complete", _update_gui)
	GameController.connect("new_district_registered", _on_new_district_registered)
	GameController.connect("agent_changed", _on_agents_changed)
	GameController.connect("new_assignment", _on_new_assignment)
	resistance_bar.value = GameController.get_resistance_level()
	heat_bar.value = GameController.get_heat_level()
	date.text = GameController.calendar.get_date_string()

	_update_gui()

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the registration of a new district.
Updates the GUI to reflect new game state.

@param district The newly registered district
"""
func _on_new_district_registered(district: District) -> void:
	_update_gui()

"""
@brief Handles changes to agent status.
Updates the agent list in the sidebar.

@param new_agent Optional parameter for the agent that changed
"""
func _on_agents_changed(new_agent: Character = null) -> void:
	# TODO: this works, and it reacts to agent_changed, but agent_changed isnt called if set directly on the character, only if set through the GameController, I'm not sure what pattern to follow here

	# clear the agents wrapper
	for child in agents_wrapper.get_children():
		child.queue_free()

	# get all recruited sympathisers
	for character in GlobalRegistry.characters.get_list(GlobalRegistry.LIST_SYMPATHISER_RECRUITED):
		var agent_instance = Globals.mini_agent_card_scene.instantiate()
		agent_instance.set_character(character)
		agents_wrapper.add_child(agent_instance)
	

"""
@brief Handles new agent assignments.
Updates the agent list to reflect new assignments.

@param option The type of action assigned
@param poi The point of interest for the assignment
@param agents Array of agents involved in the assignment
"""
func _on_new_assignment(option: Enums.ActionType, poi: PointOfInterest, agents: Array[Character]) -> void:
	_on_agents_changed(agents[0])

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Updates all GUI elements to reflect current game state.

@param number Optional parameter for turn number
"""
func _update_gui(number: int = 0) -> void:
	date.text = GameController.calendar.get_date_string()
	resistance_bar.value = GameController.get_resistance_level()
	heat_bar.value = GameController.get_heat_level()
	_on_agents_changed()
