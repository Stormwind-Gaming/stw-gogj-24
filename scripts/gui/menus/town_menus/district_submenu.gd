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
@brief Richtext label displaying the district modifiers
"""
@export var modifier_text: RichTextLabel

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
	self.name = "%s - %s" % [district.district_name, Globals.get_district_type_string(district.district_type)]
	self.district_name.text = "%s - %s" % [district.district_name, Globals.get_district_type_string(district.district_type)]
	self.description.text = ReferenceGetter.game_controller().town_details.get_district_description(district.district_type)
	
	self.heat_bar.value = district.heat
	self.heat_bar_label.text = "District Heat"
	# self.heat_bar_label.text = "Heat - %s" % str(district.heat) + "%"
	self.resistance_bar.value = district.sympathy
	match district.district_type:
		Enums.DistrictType.CIVIC:
			self.resistance_bar.max_value = Constants.CIVIC_DISTRICT_BONUS_BREAKPOINT + 1
		Enums.DistrictType.INDUSTRIAL:
			self.resistance_bar.max_value = Constants.INDUSTRIAL_DISTRICT_BONUS_BREAKPOINT + 1
		Enums.DistrictType.RESIDENTIAL:
			self.resistance_bar.max_value = Constants.RESIDENTIAL_DISTRICT_BONUS_BREAKPOINT + 1
		Enums.DistrictType.MILITARY:
			self.resistance_bar.max_value = Constants.MILITARY_DISTRICT_BONUS_BREAKPOINT + 1
		Enums.DistrictType.PORT:
			self.resistance_bar.max_value = Constants.PORT_DISTRICT_BONUS_BREAKPOINT + 1
	self.resistance_bar_label.text = "District Resistance"
	# self.resistance_bar_label.text = "Resistance - %s" % str(district.sympathy) + "%"
	
	var bonuses = ReferenceGetter.global_registry().modifiers.get_all_items().filter(func(x): return x.active == true and x.district == district)
	modifier_text.text = ""
	if bonuses.size() > 0:
		modifier_text.text += "[font_size=20]Active Effects:[/font_size]\n"
		for bonus in bonuses:
			print(bonus)
			modifier_text.text += "%s - %s" % [bonus.modifier_name, bonus.get_modification_effect_text()]
			modifier_text.text += "\n"

	# for poi in district.pois add a new button to the poi_buttons container
	for poi in district.pois:
		var button = Button.new()
		button.text = poi.poi_name
		button.pressed.connect(_on_poi_button_pressed.bind(poi))
		button.size_flags_horizontal = HORIZONTAL_ALIGNMENT_FILL 
		self.poi_buttons.add_child(button)

#|==============================|
#|       Event Handlers        |
#|==============================|
"""
@brief Handles the pressing of a PoI button
"""
func _on_poi_button_pressed(poi: PointOfInterest) -> void:
	self.poi_selected.emit(poi)

"""
@brief Event handler for the focus button
"""
func _on_focus_button_pressed() -> void:
	EventBus.close_all_windows.emit()
	district.district_clicked.emit(district)
