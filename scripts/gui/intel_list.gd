extends Window

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Container for Who/What button groups
"""
@onready var whowhat_btn_grp_container = find_child("WhoWhatBtnGrpContainer")

"""
@brief Container for Where button groups
"""
@onready var where_btn_grp_container = find_child("WhereBtnGrpContainer")

"""
@brief Container for When button groups
"""
@onready var when_btn_grp_container = find_child("WhenBtnGrpContainer")

"""
@brief Description label for Who/What intel
"""
@onready var whowhat_description = find_child("WhoWhatDescription")

"""
@brief Description label for Where intel
"""
@onready var where_description = find_child("WhereDescription")

"""
@brief Description label for When intel
"""
@onready var when_description = find_child("WhenDescription")

"""
@brief Container for the plan list
"""
@onready var plan_list_container = find_child("PlanListContainer")

"""
@brief Container for all tabs
"""
@onready var tab_container = find_child("TabContainer")

"""
@brief Container for the plan holder
"""
@export var plan_holder: HBoxContainer

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Reference to the current plan scene
"""
var plan_scene: PanelContainer

"""
@brief Dictionary to store selected intel for each type
"""
var selected_intel = {
	Enums.RumourType.MISSION: null,
	Enums.RumourType.LOCATION: null,
	Enums.RumourType.TIME: null
}

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Initializes the intel list and plan creation interface.
"""
func _ready():
	# Connect the tab change signal
	tab_container.tab_changed.connect(_on_tab_changed)
	
	populate_rumour_list()
	populate_plan_list()

	# create a new plan
	var new_plan_scene = Globals.plan_scene.instantiate()
	new_plan_scene.set_new_plan_card()
	new_plan_scene.toggle_enabled_button(false)
	new_plan_scene.create_plan.connect(_on_create_plan_btn_pressed)
	plan_holder.add_child(new_plan_scene)
	plan_scene = new_plan_scene

#|==============================|
#|      Helper Functions       |
#|==============================|
"""
@brief Open at plan page
"""
func open_at_plan_page():
	tab_container.current_tab = 1

"""
@brief Clears all child nodes from a container.

@param container The container to clear
"""
func clear_container(container):
	while container.get_child_count() > 0:
		container.remove_child(container.get_child(0))

"""
@brief Populates the intel list with available intel items.

@param intel Dictionary of intel items to display
"""
func populate_rumour_list():
	# Clear any existing controls in the containers
	clear_container(whowhat_btn_grp_container)
	clear_container(where_btn_grp_container)
	clear_container(when_btn_grp_container)
	
	var intel_type_to_container = {
		Enums.RumourType.MISSION: {"container": whowhat_btn_grp_container, "button_group": ButtonGroup.new(), "description_label": whowhat_description, "intel_type": Enums.RumourType.MISSION},
		Enums.RumourType.LOCATION: {"container": where_btn_grp_container, "button_group": ButtonGroup.new(), "description_label": where_description, "intel_type": Enums.RumourType.LOCATION},
		Enums.RumourType.TIME: {"container": when_btn_grp_container, "button_group": ButtonGroup.new(), "description_label": when_description, "intel_type": Enums.RumourType.TIME}
	}

	var rumours = ReferenceGetter.global_registry().intel.get_list(ReferenceGetter.global_registry().LIST_RUMOURS)
	for rumour in rumours:
		var intel_data = intel_type_to_container.get(rumour.rumour_type)

		if intel_data and intel_data["container"]:
			var container = intel_data["container"]
			var button_group = intel_data["button_group"]
			var description_label = intel_data["description_label"]

			button_group.allow_unpress = true

			var check_button = CheckButton.new()
			check_button.text = rumour.rumour_text + " (Expires in " + str(rumour.expires_on_turn - ReferenceGetter.game_controller().turn_number) + " days)"
			check_button.set_button_group(button_group)
			check_button.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
			check_button.focus_mode = 0

			# Store reference to rumour object
			check_button.set_meta("rumour", rumour)

			# Use a lambda to update selected intel and toggle button visibility
			check_button.toggled.connect(func(pressed, intel_type = rumour.rumour_type, rumour_ref = rumour):
				if pressed:
					selected_intel[intel_type] = rumour_ref
					match intel_type:
						Enums.RumourType.MISSION:
							plan_scene.set_mission_text(Globals.get_intel_effect_string(rumour_ref.rumour_effect, true))
						Enums.RumourType.LOCATION:
							plan_scene.set_location_text(Globals.get_intel_effect_string(rumour_ref.rumour_effect, true))
						Enums.RumourType.TIME:
							plan_scene.set_time_text(Globals.get_intel_effect_string(rumour_ref.rumour_effect, true))
						_:
							pass
				else:
					selected_intel[intel_type] = null
					match intel_type:
						Enums.RumourType.MISSION:
							plan_scene.set_mission_text('')
						Enums.RumourType.LOCATION:
							plan_scene.set_location_text('')
						Enums.RumourType.TIME:
							plan_scene.set_time_text('')
						_:
							pass
				_check_create_plan_visibility()
			)

			if rumour.rumour_type == Enums.RumourType.MISSION and rumour.rumour_effect == Enums.IntelEffect.RESCUE_AGENT:
				# check if there is anyone to rescue
				var agents = ReferenceGetter.global_registry().characters.get_list(ReferenceGetter.global_registry().LIST_MIA)
				if len(agents) == 0:
					check_button.disabled = true


			container.add_child(check_button)
			container.add_child(HSeparator.new())
		else:
			print("Error: Container not found or intel_data is invalid for:", name, "with type:", rumour.type)
	
	# if any container is empty, show a message
	for intel_data in intel_type_to_container.values():
		if intel_data["container"].get_child_count() == 0:
			# create a label
			var label = Label.new()
			label.text = "No %s type intel available" % Globals.get_intel_type_string(intel_data["intel_type"])
			label.add_theme_font_size_override("font_size", 14)
			intel_data["container"].add_child(label)

"""
@brief Populates the plan list with existing plans.

@param intel Dictionary of intel items to filter for plans
"""
func populate_plan_list():
	var plans = ReferenceGetter.global_registry().intel.get_list(ReferenceGetter.global_registry().LIST_PLANS)

	# Clear any existing elements in the plan_list_container
	clear_container(plan_list_container)

	# Loop over intel and add labels for nodes with level PLAN
	for plan in plans:
		var new_plan_scene = Globals.plan_scene.instantiate()
		new_plan_scene.toggle_enabled_button(false)
		new_plan_scene.set_existing_plan_card(plan)
		new_plan_scene.create_plan.connect(_on_create_plan_btn_pressed)
		plan_list_container.add_child(new_plan_scene)
	
	if len(plans) == 0:
		# create a label
		var margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_top", 20)
		margin_container.add_theme_constant_override("margin_left", 10)
		var label = Label.new()
		label.text = "No plans available, combine Rumours to formulate a new plan."
		margin_container.add_child(label)
		plan_list_container.add_child(margin_container)

"""
@brief Checks if a plan can be created and updates button visibility.
"""
func _check_create_plan_visibility():
	# Check if all intel types have a selected intel node
	if selected_intel[Enums.RumourType.MISSION] and selected_intel[Enums.RumourType.LOCATION] and selected_intel[Enums.RumourType.TIME]:
		plan_scene.toggle_enabled_button(true)
	else:
		plan_scene.toggle_enabled_button(false)

"""
@brief Resets the selected intel and plan display.
"""
func _reset():
	selected_intel = {
		Enums.RumourType.MISSION: null,
		Enums.RumourType.LOCATION: null,
		Enums.RumourType.TIME: null
	}
	
	plan_scene.set_mission_text('')
	plan_scene.set_location_text('')
	plan_scene.set_time_text('')
	
	plan_scene.toggle_enabled_button(false)

#|==============================|
#|      Event Handlers         |
#|==============================|
"""
@brief Handles the create plan button press.
Creates a new plan from selected intel pieces.
"""
func _on_create_plan_btn_pressed():
	# Ensure all required intel are selected
	var required_intel = [
		selected_intel[Enums.RumourType.MISSION],
		selected_intel[Enums.RumourType.LOCATION],
		selected_intel[Enums.RumourType.TIME]
	]
	
	# Call IntelFactory.combine_rumours with the selected intel nodes
	IntelFactory.formulate_plan(required_intel[0], required_intel[1], required_intel[2])
	
	# Switch to the 'Plans' tab
	tab_container.current_tab = 1

"""
@brief Handles tab changes in the intel list.
Refreshes the intel and plan lists.

@param tab_index The index of the newly selected tab
"""
func _on_tab_changed(tab_index):
	# Re-run both populate_plan_list and populate_intel_list when the tab changes
	_reset()
	populate_rumour_list()
	populate_plan_list()

"""
@brief Handles the close button press.
"""
func _on_close_button_pressed() -> void:
	EventBus.close_window.emit()
