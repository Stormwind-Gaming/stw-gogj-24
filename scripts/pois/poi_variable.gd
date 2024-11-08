extends PointOfInterest

func _init(poi_variable_name_arg: String = '', poi_variable_description_arg: String = '') -> void:
	set_poi_details(parent_district, poi_variable_name_arg, poi_variable_description_arg)
