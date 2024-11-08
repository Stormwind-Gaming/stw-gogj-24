extends Window

@onready var intel_list_container = $PanelContainer/MarginContainer/IntelListContainer

func _ready():
	# Connect the close_requested signal
	connect("close_requested", Callable(self, "_on_close_requested"))
	
	# Fetch intel from the GlobalRegistry and populate the list
	var intel = GlobalRegistry.get_all_objects(GlobalRegistry.Registry_Category.INTEL)
	populate_intel_list(intel)

func _on_close_requested():
	queue_free()

func populate_intel_list(intel):
	# Clear existing children in the container by freeing them
	for child in intel_list_container.get_children():
		child.queue_free()

	# Iterate over the dictionary to create buttons
	for name in intel.keys():
		var intel_node = intel[name]
		var label = Label.new()

		# Use character_node's first_name and last_name for the button text
		label.text = intel_node.description

		intel_list_container.add_child(label)
