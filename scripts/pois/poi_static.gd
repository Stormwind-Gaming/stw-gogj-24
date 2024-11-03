extends PointOfInterest

@export var poi_static_name: String = ""
@export_multiline var poi_static_description: String = ""

func _ready() -> void:
	set_poi_details(poi_static_name, poi_static_description)
