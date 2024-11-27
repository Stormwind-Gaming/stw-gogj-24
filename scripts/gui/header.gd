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
@export var heat_bar_label: Label

"""
@brief Progress bar showing the current resistance level
"""
@export var resistance_bar: ProgressBar
@export var resistance_bar_label: Label

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
	EventBus.district_created.connect(_on_new_district_registered)
	EventBus.end_turn_complete.connect(_update_gui)
	EventBus.character_recruitment_state_changed.connect(_on_agents_changed)
	EventBus.action_created.connect(_on_new_assignment)
	EventBus.character_sympathy_changed.connect(_update_on_character_sympathy_change)

	var res = GameController.get_resistance_level()
	resistance_bar.value = res
	resistance_bar.max_value = Constants.RESISTANCE_ENDGAME_THRESHOLD + 1
	resistance_bar_label.text = "Resistance"
	# resistance_bar_label.text = "Resistance - %s" % str(res) + "%"

	var heat = GameController.get_heat_level()
	heat_bar.value = heat
	heat_bar.max_value = Constants.HEAT_ENDGAME_THRESHOLD + 1
	heat_bar_label.text = "Heat"
	# heat_bar_label.text = "Heat - %s" % str(heat) + "%"
	date.text = GameController.calendar.get_date_string()

	

	_update_gui()

	# wait one second
	await get_tree().create_timer(1.0).timeout
	agents_wrapper.visible = true

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
func _on_agents_changed(new_agent: Character) -> void:
	_update_agents_gui()

func _update_agents_gui() -> void:
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
func _on_new_assignment(action: BaseAction) -> void:
	_update_agents_gui()

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Updates all GUI elements to reflect current game state.

@param number Optional parameter for turn number
"""
func _update_gui(_number: int = 0) -> void:
	date.text = GameController.calendar.get_date_string()

	var res = GameController.get_resistance_level()
	resistance_bar.value = res
	resistance_bar_label.text = "Resistance"
	# resistance_bar_label.text = "Resistance - %s" % str(res) + "%"
	
	var heat = GameController.get_heat_level()
	heat_bar.value = heat
	heat_bar_label.text = "Heat"
	# heat_bar_label.text = "Heat - %s" % str(heat) + "%"
	_update_agents_gui()

func _update_on_character_sympathy_change(character: Character) -> void:
	_update_gui()
