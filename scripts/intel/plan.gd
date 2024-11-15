extends BaseIntel

class_name Plan

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the plan is initialized.
Sets up initial values and registers with the global registry.
"""
func _init():
	super()
	print('Plan init')
	# Register the object after setting properties
	GlobalRegistry.intel.add_item(GlobalRegistry.LIST_RUMOURS, self)
