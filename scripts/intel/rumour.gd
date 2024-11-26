extends BaseIntel

class_name Rumour

#|==============================|
#|      Inner Classes          |
#|==============================|
"""
@brief Properties class to hold rumour configuration data
"""
class RumourProperties:
	var rumour_text: String
	var rumour_type: Enums.RumourType
	var rumour_effect: Enums.IntelEffect
	var rumour_subject_character: Character
	var rumour_subject_poi: PointOfInterest
	var rumour_subject_duration: int
	var rumour_subject_expiry: int

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief The text content of the rumour
"""
var rumour_text: get = _get_rumour_text

"""
@brief The type of rumour (mission, location, time)
"""
var rumour_type: Enums.RumourType

"""
@brief The effect this rumour has when used
"""
var rumour_effect: Enums.IntelEffect

"""
@brief Character this rumour is about (if applicable)
"""
var rumour_subject_character: Character

"""
@brief Point of Interest this rumour is about (if applicable)
"""
var rumour_subject_poi: PointOfInterest

"""
@brief Duration of the rumour's effect
"""
var rumour_subject_duration: int

"""
@brief When the rumour's effect expires
"""
var rumour_subject_expiry: int

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Initializes the rumour with the provided properties.

@param properties RumourProperties object containing the initial configuration
"""
func _init(properties: RumourProperties):
	super()
	LogDuck.d("Initializing new rumour", {
		"type": properties.rumour_type,
		"effect": properties.rumour_effect,
		"character": properties.rumour_subject_character.get_full_name() if properties.rumour_subject_character else "None",
		"poi": properties.rumour_subject_poi.poi_name if properties.rumour_subject_poi else "None",
		"duration": properties.rumour_subject_duration,
		"expiry": properties.rumour_subject_expiry
	})

	# Set properties
	rumour_text = properties.rumour_text
	rumour_type = properties.rumour_type
	rumour_effect = properties.rumour_effect
	rumour_subject_character = properties.rumour_subject_character
	rumour_subject_poi = properties.rumour_subject_poi
	rumour_subject_duration = properties.rumour_subject_duration
	rumour_subject_expiry = properties.rumour_subject_expiry

	expires_on_turn = GameController.turn_number + Constants.RUMOUR_EXPIRY_TURNS
	LogDuck.d("Rumour expiry set", {
		"current_turn": GameController.turn_number,
		"expires_on": expires_on_turn,
		"expiry_turns": Constants.RUMOUR_EXPIRY_TURNS
	})

	# Register the object after setting properties
	EventBus.rumour_created.emit(self)
	LogDuck.d("Rumour creation complete and emitted", {
		"text_length": rumour_text.length(),
		"has_character": rumour_subject_character != null,
		"has_poi": rumour_subject_poi != null
	})

func _get_rumour_text() -> String:
	LogDuck.d("Getting formatted rumour text", {
		"raw_text": rumour_text,
		"has_character": rumour_subject_character != null,
		"has_poi": rumour_subject_poi != null
	})
	
	var replacement_map = {
		"character": rumour_subject_character.char_full_name if rumour_subject_character != null else "Unknown Character",
		"poi": rumour_subject_poi.poi_name if rumour_subject_poi != null else "Unknown POI",
	}

	var formatted_text = rumour_text.format(replacement_map)
	LogDuck.d("Rumour text formatted", {
		"character_replacement": replacement_map["character"],
		"poi_replacement": replacement_map["poi"],
		"final_length": formatted_text.length()
	})
	
	return formatted_text