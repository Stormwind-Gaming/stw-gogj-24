extends PanelContainer



#|==============================|
#|       Properties            |
#|==============================|
"""
@brief The district
"""
var district: District

"""
@brief Label displaying the district name
"""
@export var district_name: Label

"""
@brief Progress bar showing the district heat level
"""
@export var heat_bar: ProgressBar

"""
@brief Label for the heat bar
"""
@export var heat_bar_label: Label

"""
@brief Progress bar showing the district resistance level
"""
@export var resistance_bar: ProgressBar

"""
@brief Label for the resistance bar
"""
@export var resistance_bar_label: Label

"""
@brief Richtext label displaying the district description
"""
@export var description: RichTextLabel

"""
@brief Container of the PoI buttons
"""
@export var poi_buttons: GridContainer

#|==============================|
#|       Signals               |
#|==============================|

signal poi_selected(poi: PointOfInterest)

#|==============================|
#|       Methods               |
#|==============================|
"""
@brief Initializes the district submenu
"""
func set_district(district: District) -> void:
	self.district = district
	self.name = district.district_name
	self.district_name.text = district.district_name
	self.description.text = GameController.town_details.get_district_description(district.district_type)
	
	self.heat_bar.value = district.heat
	self.heat_bar_label.text = "Heat - %s" % str(district.heat) + "%"
	self.resistance_bar.value = district.sympathy
	self.resistance_bar_label.text = "Resistance - %s" % str(district.sympathy) + "%"

	# for poi in district.pois add a new button to the poi_buttons container
	for poi in district.pois:
		var button = Button.new()
		button.text = poi.poi_name
		button.pressed.connect(_on_poi_button_pressed)
		button.size_flags_horizontal = HORIZONTAL_ALIGNMENT_FILL 
		self.poi_buttons.add_child(button)
	
	pass

#|==============================|
#|       Event Handlers        |
#|==============================|
"""
@brief Handles the pressing of a PoI button
"""
func _on_poi_button_pressed() -> void:
	# var poi = self.district.pois[poi_int]
	# self.poi_selected.emit(poi)
	print("PoI button pressed")

"""
@brief Event handler for the focus button
"""
func _on_foucus_button_pressed() -> void:
	WindowHandler._close_all_windows()
	district.district_clicked.emit(district)
