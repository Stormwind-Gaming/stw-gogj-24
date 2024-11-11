extends Window

@onready var whowhat_btn_grp_container = find_child("WhoWhatBtnGrpContainer")
@onready var where_btn_grp_container = find_child("WhereBtnGrpContainer")
@onready var when_btn_grp_container = find_child("WhenBtnGrpContainer")

@onready var whowhat_description = find_child("WhoWhatDescription")
@onready var where_description = find_child("WhereDescription")
@onready var when_description = find_child("WhenDescription")

@onready var create_plan_btn = find_child("CreatePlanBtn")
@onready var plan_list_container = find_child("PlanListContainer")
@onready var tab_container = find_child("TabContainer")


# Variables to store selected intel nodes
var selected_intel = {
	Enums.IntelType.WHOWHAT: null,
	Enums.IntelType.WHERE: null,
	Enums.IntelType.WHEN: null
}

func _ready():
	create_plan_btn.visible = false
	create_plan_btn.pressed.connect(_on_create_plan_btn_pressed)
	
	# Connect the tab change signal
	tab_container.tab_changed.connect(_on_tab_changed)
	
	# Fetch intel from the GlobalRegistry and populate the list
	var intel = GlobalRegistry.get_all_objects(Enums.Registry_Category.INTEL)
	populate_intel_list(intel)
	populate_plan_list(intel)

func clear_container(container):
	while container.get_child_count() > 0:
		container.remove_child(container.get_child(0))

func populate_intel_list(intel):
	# Clear any existing controls in the containers
	clear_container(whowhat_btn_grp_container)
	clear_container(where_btn_grp_container)
	clear_container(when_btn_grp_container)
	
	var intel_type_to_container = {
		Enums.IntelType.WHOWHAT: { "container": whowhat_btn_grp_container, "button_group": ButtonGroup.new(), "description_label": whowhat_description },
		Enums.IntelType.WHERE: { "container": where_btn_grp_container, "button_group": ButtonGroup.new(), "description_label": where_description },
		Enums.IntelType.WHEN: { "container": when_btn_grp_container, "button_group": ButtonGroup.new(), "description_label": when_description }
	}

	for name in intel.keys():
		var intel_node = intel[name]
		var intel_data = intel_type_to_container.get(intel_node.type)

		if intel_data and intel_data["container"]:
			var container = intel_data["container"]
			var button_group = intel_data["button_group"]
			var description_label = intel_data["description_label"]

			var check_button = CheckButton.new()
			check_button.text = intel_node.description
			check_button.set_button_group(button_group)
			check_button.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)

			# Use a lambda to update selected intel and toggle button visibility
			check_button.toggled.connect(func(pressed, intel_type=intel_node.type, node=intel_node):
				if pressed:
					selected_intel[intel_type] = node
					description_label.text = Globals.get_intel_effect_string(node.effect)
				else:
					selected_intel[intel_type] = null
					description_label.text = ""
				_check_create_plan_visibility()
			)

			container.add_child(check_button)
		else:
			print("Error: Container not found or intel_data is invalid for:", name, "with type:", intel_node.type)

func populate_plan_list(intel):
	# Clear any existing elements in the plan_list_container
	clear_container(plan_list_container)

	# Loop over intel and add labels for nodes with level PLAN
	for name in intel.keys():
		var intel_node = intel[name]
		if intel_node.level == Enums.IntelLevel.PLAN:
			var label = Label.new()
			label.text = intel_node.description
			plan_list_container.add_child(label)

func _check_create_plan_visibility():
	# Check if all intel types have a selected intel node
	if selected_intel[Enums.IntelType.WHOWHAT] and selected_intel[Enums.IntelType.WHERE] and selected_intel[Enums.IntelType.WHEN]:
		create_plan_btn.visible = true
	else:
		create_plan_btn.visible = false

func _on_create_plan_btn_pressed():
	# Ensure all required intel are selected
	var required_intel = [
		selected_intel[Enums.IntelType.WHOWHAT],
		selected_intel[Enums.IntelType.WHERE],
		selected_intel[Enums.IntelType.WHEN]
	]
	
	# Call IntelFactory.combine_rumours with the selected intel nodes
	var plan = IntelFactory.combine_rumours(required_intel)
	
	if plan:
		# Optionally, you can add the new plan to the GlobalRegistry or handle it accordingly
		# print("Plan created successfully.")
		pass
	
	# Switch to the 'Plans' tab
	tab_container.current_tab = 1

func _on_tab_changed(tab_index):
	# Re-run both populate_plan_list and populate_intel_list when the tab changes
	var intel = GlobalRegistry.get_all_objects(Enums.Registry_Category.INTEL)
	_reset()
	populate_intel_list(intel)
	populate_plan_list(intel)
	
func _reset():
	selected_intel = {
		Enums.IntelType.WHOWHAT: null,
		Enums.IntelType.WHERE: null,
		Enums.IntelType.WHEN: null
	}
	
	whowhat_description.text = ""
	where_description.text = ""
	when_description.text = ""
	
	create_plan_btn.visible = false


func _on_close_button_pressed() -> void:
	queue_free()
