extends WindowWithCleanup

var district_submenu_scene = preload("res://scenes/gui/menus/town_menus/district_submenu.tscn")
var poi_submenu_scene = preload("res://scenes/gui/menus/town_menus/poi_submenu.tscn")

#|==============================|
#|    Exported Properties       |
#|==============================|
"""
@brief The tab container
"""
@export var tab_container: TabContainer

"""
@brief The town tab
"""
@export var town_tab: PanelContainer

"""
@brief The town name label
"""
@export var town_name_label: Label

"""
@brief The town popupation label
"""
@export var town_population_label: Label

"""
@brief The resistance bar
"""
@export var resistance_bar: ProgressBar

"""
@brief The resistance bar label
"""
@export var resistance_bar_label: Label

"""
@brief The heat bar
"""
@export var heat_bar: ProgressBar

"""
@brief The heat bar label
"""
@export var heat_bar_label: Label

"""
@brief The active bonuses RichTextLabel
"""
@export var active_bonuses: RichTextLabel

"""
@brief The active World Events RichTextLabel
"""
@export var active_world_events: RichTextLabel

"""
@brief The town description
"""
@export var town_description: RichTextLabel
#|==============================|
#|      Lifecycle Methods       |
#|==============================|
"""
@brief Called when the node enters the scene tree
"""
func _ready() -> void:
	# connect signals
	EventBus.open_district_window.connect(_open_to_district)
	EventBus.open_poi_window.connect(_open_to_poi)

	town_tab.name = ReferenceGetter.game_controller().town_details.town_name
	town_name_label.text = ReferenceGetter.game_controller().town_details.town_name
	town_population_label.text = "Pop: %s" % str(ReferenceGetter.game_controller().town_details.popupation)
	
	var res = ReferenceGetter.game_controller().get_resistance_level()
	resistance_bar.value = res
	resistance_bar.max_value = Constants.RESISTANCE_ENDGAME_THRESHOLD + 1
	resistance_bar_label.text = "Resistance"
	# resistance_bar_label.text = "Resistance - %s" % str(res) + "%"
	
	var heat = ReferenceGetter.game_controller().get_heat_level()
	heat_bar.value = heat
	heat_bar.max_value = Constants.HEAT_ENDGAME_THRESHOLD + 1
	heat_bar_label.text = "Heat"
	# heat_bar_label.text = "Heat - %s" % str(heat) + "%"

	town_description.text = ReferenceGetter.game_controller().town_details.description

	tab_container.tab_changed.connect(_on_tab_button_pressed)

	# active bonuses

	var bonuses = ReferenceGetter.global_registry().modifiers.get_list(ReferenceGetter.global_registry().LIST_GLOBAL_MODIFIERS).filter(func(x): return x.active == true)
	active_bonuses.text = ""
	if bonuses.size() > 0:
		active_bonuses.text += "[font_size=20]Active Bonuses:[/font_size]\n"
		for bonus in bonuses:
			print(bonus)
			active_bonuses.text += "%s - %s" % [bonus.modifier_name, bonus.get_modification_effect_text()]
			active_bonuses.text += "\n"
	
	# world events
	var events = ReferenceGetter.global_registry().world_events.get_list(ReferenceGetter.global_registry().LIST_WORLD_EVENTS)
	active_world_events.text = ""
	if events.size() > 0:
		for event in events:
			# check validity as previously free events that are not removed cause errors
			if is_instance_valid(event):
				if active_world_events.text != "":
					active_world_events.text += "[font_size=20]World Events:[/font_size]\n"

				active_world_events.text += "%s: %s Day" % [event.event_data.event_title, str(event.turn_to_end - ReferenceGetter.game_controller().turn_number)]
				if (event.turn_to_end - ReferenceGetter.game_controller().turn_number) > 1:
					active_world_events.text += "s"
				active_world_events.text +=" left" + "\n"
			else:
				events.erase(event)
	
	if bonuses.size() == 0 and events.size() == 0:
		active_bonuses.text = "No active bonuses or world events"
		active_world_events.text = ""


#|==============================|
#|         Event listeners      |
#|==============================|
"""
@brief Called when the close button is pressed
"""
func _on_close_button_pressed() -> void:
	EventBus.close_window.emit()

"""
@brief Called when the civic button is pressed
"""
func _on_district_button_pressed(district_enum: Enums.DistrictType) -> void:
	var district_submenu = district_submenu_scene.instantiate()
	district_submenu.set_district(ReferenceGetter.global_registry().districts.find_item(ReferenceGetter.global_registry().LIST_ALL_DISTRICTS, "district_type", district_enum))
	tab_container.add_child(district_submenu)
	tab_container.set_current_tab(tab_container.get_tab_count() - 1)
	district_submenu.poi_selected.connect(_on_poi_button_pressed)

func _on_poi_button_pressed(poi: PointOfInterest) -> void:
	var poi_submenu = poi_submenu_scene.instantiate()
	poi_submenu.set_poi(poi)
	tab_container.add_child(poi_submenu)
	tab_container.set_current_tab(tab_container.get_tab_count() - 1)
	
"""
@brief Called when the tab is changed
"""
func _on_tab_button_pressed(tab: int) -> void:
	# remove all tabs after the tab that was clicked
	for i in range(tab_container.get_tab_count() - 1, tab, -1):
		tab_container.remove_child(tab_container.get_child(i))

"""
@brief Opens the town details list to the given district

@param district The district to open to
"""
func _open_to_district(district: District) -> void:
	var district_submenu = district_submenu_scene.instantiate()
	district_submenu.set_district(district)
	tab_container.add_child(district_submenu)
	tab_container.set_current_tab(tab_container.get_tab_count() - 1)
	district_submenu.poi_selected.connect(_on_poi_button_pressed)

"""
@brief Opens the town details list to the given point of interest
"""	
func _open_to_poi(poi: PointOfInterest) -> void:
	LogDuck.d("Opening to POI: %s" % poi)
	# first open its district
	var district_submenu = district_submenu_scene.instantiate()
	district_submenu.set_district(poi.parent_district)
	district_submenu.poi_selected.connect(_on_poi_button_pressed)
	tab_container.add_child(district_submenu)
	var poi_submenu = poi_submenu_scene.instantiate()
	poi_submenu.set_poi(poi)
	tab_container.add_child(poi_submenu)
	tab_container.set_current_tab(tab_container.get_tab_count() - 1)
