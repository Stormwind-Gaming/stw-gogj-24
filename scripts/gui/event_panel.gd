extends WindowWithCleanup

#|==============================|
#|      Exported Variables       |
#|==============================|

@export var event_image: TextureRect
@export var title_label: Label
@export var text_label: RichTextLabel
@export var button: Button

#|==============================|
#|      Local Variables       	|
#|==============================|
"""
@brief The log that this event panel is displaying
"""
# var log: TurnLog

#|==============================|
#|      Signals					       	|
#|==============================|

"""
@brief Emitted when the close button is pressed
"""
signal on_close(event_panel: Window)

#|==============================|
#|    Getters and Setters       |
#|==============================|
"""
@brief Sets the character for the agent card.

@param event_type The type of the event being displayed.
@param title The title of the event.
@param text The text of the event.
@param button_text The text of the button.
"""
func set_event_details(event_type: Enums.EventOutcomeType, characters: Array[Character], poi: PointOfInterest, title_attr: String = "", text_attr: String = "", button_text_attr: String = "") -> void:
	# get the event type image
	event_image.texture = Globals.event_images[event_type]
	var event_outcome_text_objects = Globals.event_outcome_text[event_type]
	var event_outcome_text_object = event_outcome_text_objects[randi() % event_outcome_text_objects.size()]
	# set the title, text, and button text
	if title_attr == "":
		title_label.text = event_outcome_text_object.title
	else:
		title_label.text = title_attr
	if text_attr == "":
		text_label.text = event_outcome_text_object.text
	else:
		text_label.text = text_attr
	if button_text_attr == "":
		button.text = event_outcome_text_object.button_text
	else:
		button.text = button_text_attr
	
	# replace the placeholders in the text
	text_label.text = text_label.text.replace("{town}", ReferenceGetter.game_controller().town_details.town_name)
	title_label.text = title_label.text.replace("{town}", ReferenceGetter.game_controller().town_details.town_name)
	if characters.size() > 0:
		text_label.text = text_label.text.replace("{character}", characters[0].get_full_name())
		title_label.text = title_label.text.replace("{character}", characters[0].get_full_name())
	if poi:
		text_label.text = text_label.text.replace("{district}", poi.parent_district.district_name).replace("{poi}", poi.poi_name)
		title_label.text = title_label.text.replace("{district}", poi.parent_district.district_name).replace("{poi}", poi.poi_name)


func set_event_details_world_event(world_event: WorldEvent) -> void:
	if not world_event.event_data:
		return
	# get the event type image
	print(world_event.event_data)
	event_image.texture = Globals.world_event_images[world_event.event_data.event_type]
	var event_outcome_text_object = world_event.event_data
	# set the title, text, and button text
	
	title_label.text = event_outcome_text_object.event_title
	text_label.text = world_event.event_data.event_text
	button.text = event_outcome_text_object.event_button_text
	
	# replace the placeholders in the text
	text_label.text = text_label.text.replace("{town}", ReferenceGetter.game_controller().town_details.town_name)
	title_label.text = title_label.text.replace("{town}", ReferenceGetter.game_controller().town_details.town_name)
	if world_event.event_character:
		text_label.text = text_label.text.replace("{character}", world_event.event_character.get_full_name())
		title_label.text = title_label.text.replace("{character}", world_event.event_character.get_full_name())
	if world_event.event_district:
		text_label.text = text_label.text.replace("{district}", world_event.event_district.district_name)
		title_label.text = title_label.text.replace("{district}", world_event.event_district.district_name)
	if world_event.event_poi:
		text_label.text = text_label.text.replace("{poi}", world_event.event_poi.poi_name)
		title_label.text = title_label.text.replace("{poi}", world_event.event_poi.poi_name)

func set_event_endgame_event(event: Enums.EventOutcomeType) -> void:
	# get the event type image
	event_image.texture = Globals.endgame_event_images[event]
	var event_outcome_text_object = Globals.event_outcome_text[event][0]
	# set the title, text, and button text
	title_label.text = event_outcome_text_object.title
	text_label.text = event_outcome_text_object.text
	button.text = event_outcome_text_object.button_text


#|==============================|
#|       Event Listeners        |
#|==============================|

"""
@brief Handle the button being pressed
"""
func _on_button_pressed() -> void:
	on_close.emit(self)
