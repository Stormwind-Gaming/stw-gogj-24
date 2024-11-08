extends PointOfInterest

@export var poi_static_name: String = ""
@export_multiline var poi_static_description: String = ""

func _init() -> void:
	set_poi_details(parent_district, poi_static_name, poi_static_description)
