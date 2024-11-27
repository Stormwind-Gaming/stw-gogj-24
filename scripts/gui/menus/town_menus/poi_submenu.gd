extends PanelContainer

#|==============================|
#|       Properties            |
#|==============================|
"""
@brief The poi
"""
var poi: PointOfInterest

"""
@brief Label displaying the district name
"""
@export var poi_name: Label

"""
@brief TextureRect displaying the district icon
"""
@export var poi_icon: TextureRect

"""
@brief Richtext label displaying the poi description
"""
@export var description: RichTextLabel

"""
@brief RicheTextLabel displaying the poi intel types
"""
@export var intel_types: RichTextLabel

"""
@brief PanelContainer containing the character owner of the poi
"""
@export var owner_panel: PanelContainer


#|==============================|
#|       Methods               |
#|==============================|
"""
@brief Initializes the district submenu
"""
func set_poi(poi: PointOfInterest) -> void:
	self.poi = poi
	self.name = poi.poi_name
	self.poi_name.text = poi.poi_name
	self.description.text = poi.poi_description

	# Set the icon
	self.poi_icon.texture = Globals.poi_icons[poi.poi_type]

	# Set the intel types
	var intel_text = "[font_size=18]Intel Type Chances:[/font_size]\n"

	# Gather the chances into a dictionary
	var intels = [
		{
			"Mission": poi.rumour_config.mission_chance
		},
		{
			"Location": poi.rumour_config.location_chance
			},
		{
			"Time": poi.rumour_config.time_chance
		}
	]

	# Sort the dictionary by values in descending order
	intels.sort_custom(func(x, y) -> int:
		return y.values()[0] <= x.values()[0]
	)

	# Prepare a dictionary to store the results
	var intel_ranks = {}

	# Assign ranks based on the sorted order
	for i in range(intels.size()):
		match i:
			0:
				intel_ranks[intels[i].keys()[0]] = "High"
				pass
			1:
				intel_ranks[intels[i].keys()[0]] = "Medium"
				pass
			2:
				if intels[i].values()[0] == intels[i-1].values()[0]:
					intel_ranks[intels[i].keys()[0]] = "Medium"
				else:
					intel_ranks[intels[i].keys()[0]] = "Low"
				pass
			_:
				pass

	# put the results into the richtext label
	for key in intel_ranks.keys():
		intel_text += key + ": " + intel_ranks[key] + "\n"
	
	# Set the text
	intel_types.text = intel_text

	# create a mini agent card for the owner
	var owner_card = Globals.mini_agent_card_scene.instantiate()
	owner_card.set_character(poi.poi_owner)
	self.owner_panel.add_child(owner_card)
	
	pass

#|==============================|
#|       Event Handlers        |
#|==============================|
"""
@brief Event handler for the focus button
"""
func _on_focus_button_pressed() -> void:
	EventBus.close_all_windows.emit()
	EventBus.focus_on_poi.emit(poi)
