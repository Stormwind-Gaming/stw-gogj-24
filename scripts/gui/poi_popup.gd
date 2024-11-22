extends Window

#|==============================|
#|      Exported Variables      |
#|==============================|
"""
@brief Label displaying the POI title
"""
@export var title_label: Label

"""
@brief Label displaying the POI description
"""
@export var text_label: RichTextLabel


#|==============================|
#|      Setters & Getters      |
#|==============================|
"""
@brief Sets the title and description text for the POI popup.

@param title The title of the Point of Interest
@param text The description text for the Point of Interest
"""
func set_details(poi: PointOfInterest) -> void:
	title_label.text = poi.poi_name

	text_label.text = poi.poi_short_description + '\n\n'
	text_label.text += 'Owner: [font_size=16]' + poi.poi_owner.get_full_name() + '[/font_size]\n'
	text_label.text += 'Most likely Intel Type: [font_size=16]' + poi.most_likely_intel_type + '[/font_size]\n'
	text_label.text += 'District base effect:\n[font_size=16]' + Globals.get_district_type_base_effect_string(poi.parent_district.district_type) + '[/font_size]\n'
	# if StatisticModification.check_milestone(poi.parent_district.district_type):
	# 	text_label.text += 'District bonus: [font_size=16]' + Globals.get_district_type_base_effect_string(poi.parent_district.district_type) + '[/font_size]'

func check_details() -> void:
	# TODO: IF we're adding the bonuses to the popup, we need to check them here 
	print("Checking details")
