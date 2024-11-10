extends Area2D
class_name PointOfInterest

@export var poi_static := true

@export_group("Static Variables")
@export var poi_static_type: Enums.POIType
@export var poi_static_name: String = ""
@export_multiline var poi_static_description: String = ""

var enabled: bool = false
var parent_district: District

#TODO: Dynamically change rumour_config for each POI, currently this gives all POI an equal chance of every rumour type
var rumour_config : IntelFactory.RumourConfig = IntelFactory.RumourConfig.new(25,25,25)
#TODO: Dynamically change stat_check_type for each POI, currently this gives all POI SMARTS type checks
var stat_check_type: Enums.StatCheckType = Enums.StatCheckType.SMARTS
var poi_type: Enums.POIType
var poi_name: String = ""
var poi_description: String = ""
var poi_owner:Character

# Variables for scale animation
var no_color = Color(0, 0, 0, 0) # No color
var selectable_color = Color(0, 1, 0, 0.5) # No color
var highlight_color = Color(1, 1, 1, 0.5) # Orange color

signal poi_hovered
signal poi_unhovered

func _ready() -> void:
	parent_district = get_parent().get_parent()
	GlobalRegistry.register_object(Enums.Registry_Category.POI, self)
	GameController.connect("district_just_focused", _on_district_just_focused)
	
	# Create the owner of the POI
	self.poi_owner = CharacterFactory.create_character()

func setup_poi_visuals():
	$Polygon2D.position = self.get_global_position()
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$Polygon2D.color = no_color

func set_poi_details(parent_district_arg: District, poi_type_arg: Enums.POIType, poi_name_arg: String, poi_description_arg: String) -> void:
	parent_district = parent_district_arg
	if poi_static:
		poi_type = poi_static_type
		poi_name = poi_static_name
		poi_description = poi_static_description
	else:
		poi_type = poi_type_arg
		poi_name = poi_name_arg
		poi_description = poi_description_arg

# Function to expand on mouse hover
func _on_mouse_entered():
	if not enabled:
		return

	# check if we have a radial menu instance, if so, don't expand
	if GameController.radial_menu_open != null:
		return

	# check if parent is focused
	if GameController.district_focused != parent_district:
		return
	$Polygon2D.color = highlight_color
	emit_signal("poi_hovered", self)

# Function to return to normal size on mouse exit
func _on_mouse_exited():
	if not enabled:
		$Polygon2D.color = no_color
		await get_tree().create_timer(0.1).timeout
		if enabled:
			_on_mouse_exited()
		return
	else:
		$Polygon2D.color = selectable_color
	emit_signal("poi_unhovered")

func _on_poi_clicked(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not enabled:
		return
	# if mouse left clicked
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# if we already have an instance of the radial_menu_instance, don't create a new one
			if GameController.radial_menu_open != null:
				return
			
			# check if parent is focused
			if GameController.district_focused != parent_district:
				return
			# create a radial menu
			var radial_menu_instance = Globals.radial_menu_scene.instantiate()
			radial_menu_instance.position = get_local_mouse_position()
			add_child(radial_menu_instance)

			GameController.open_radial_menu(radial_menu_instance, self)

func _on_district_just_focused(district: District) -> void:
	if district == parent_district:
		# set color to selectable
		$Polygon2D.color = selectable_color
		# helper timer to get around erroneous clickthroughs
		await get_tree().create_timer(0.1).timeout
		enabled = true
	else:
		$Polygon2D.color = no_color
		enabled = false
	
	
