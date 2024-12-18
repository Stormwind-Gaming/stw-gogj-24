extends Control

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the node enters the scene tree.
Initializes the panel with empty text fields.
"""
func _ready() -> void:
	$MarginContainer2/RightVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/DistrictName.text = ""
	$MarginContainer2/RightVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/DistrictDescription.text = ""
	$MarginContainer2/RightVBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/PoIName.text = ""
	$MarginContainer2/RightVBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/PoIDescription.text = ""
	$MarginContainer2/RightVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Rumour.text = ""

#|==============================|
#|      Setters & Getters      |
#|==============================|
"""
@brief Updates the district details in the panel.

@param district The district to display information for, or null to clear
"""
func set_district_details(district: District = null) -> void:
	if district == null:
		$MarginContainer2/RightVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/DistrictName.text = ""
		$MarginContainer2/RightVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/DistrictDescription.text = ""
		return
	$MarginContainer2/RightVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/DistrictName.text = district.district_name
	$MarginContainer2/RightVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/DistrictDescription.text = district.district_description
	$MarginContainer2/RightVBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Rumour.text = district.rumour_text

"""
@brief Updates the Point of Interest details in the panel.

@param poi The Point of Interest to display information for, or null to clear
"""
func set_poi_details(poi: PointOfInterest = null) -> void:
	if poi == null:
		$MarginContainer2/RightVBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/PoIName.text = ""
		$MarginContainer2/RightVBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/PoIDescription.text = ""
		return
	$MarginContainer2/RightVBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/PoIName.text = poi.poi_name
	$MarginContainer2/RightVBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/PoIDescription.text = poi.poi_description
