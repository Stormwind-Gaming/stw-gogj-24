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
@brief Richtext label displaying the poi description
"""
@export var description: RichTextLabel


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
	
	pass

#|==============================|
#|       Event Handlers        |
#|==============================|
"""
@brief Event handler for the focus button
"""
func _on_focus_button_pressed() -> void:
	WindowHandler._close_all_windows()
	poi.parent_district.district_clicked.emit(poi.parent_district)
