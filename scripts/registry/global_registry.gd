extends Node

#|==============================|
#|         Overview            |
#|==============================|
"""
GlobalRegistryNew.gd

This script serves as an enhanced version of the global registry system,
using separate Registry instances to manage different types of game objects
(characters, POIs, districts, and intel).

Each Registry instance maintains its own lists for organizing related objects,
allowing for better separation of concerns and more focused management of
different game elements.
"""

const Registry = preload("res://scripts/registry/registry.gd")

# Constants
const LIST_SYMPATHISER_NOT_RECRUITED = "sympathiser_not_recruited"
const LIST_SYMPATHISER_RECRUITED = "sympathiser_recruited"
const LIST_NON_SYMPATHISER_UNKNOWN = "non_sympathiser_unknown"
const LIST_NON_SYMPATHISER_KNOWN = "non_sympathiser_known"
const LIST_MIA = "mia"
const LIST_INCARCERATED = "incarcerated"
const LIST_DECEASED = "deceased"
const LIST_ALL_POIS = "all_pois"
const LIST_RUMOURS = "rumours"
const LIST_PLANS = "plans"

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Registry instance for managing character-related lists
"""
var characters : Registry = Registry.new()

"""
@brief Registry instance for managing POI-related lists
"""
var pois : Registry = Registry.new()

"""
@brief Registry instance for managing district-related lists
"""
var districts : Registry = Registry.new()

"""
@brief Registry instance for managing intel-related lists
"""
var intel : Registry = Registry.new()

#|==============================|
#|      Initialization         |
#|==============================|
"""
@brief Initializes all registry lists
Creates the necessary lists in each Registry instance
"""
func _init():
	# Initialize character-related lists
	characters.create_list(LIST_SYMPATHISER_RECRUITED)
	characters.create_list(LIST_SYMPATHISER_NOT_RECRUITED)
	characters.create_list(LIST_NON_SYMPATHISER_UNKNOWN)
	characters.create_list(LIST_NON_SYMPATHISER_KNOWN)
	characters.create_list(LIST_DECEASED)
	characters.create_list(LIST_MIA)
	characters.create_list(LIST_INCARCERATED)
	# Initialize POI-related lists
	pois.create_list(LIST_ALL_POIS)

	# Initialize district-related lists
	districts.create_list("all_districts")

	# Initialize intel-related lists
	intel.create_list("rumours")
	intel.create_list("plans")

#|==============================|
#|     Character Management    |
#|==============================|

"""
@brief Adds a character to the appropriate list based on their properties

@param character The character to add to the registry
"""
func add_character(character: Character) -> void:
	var target_list_name = _get_character_list(character)
	print('adding character to list', target_list_name)
	_bind_character_signals(character)
	characters.add_item(target_list_name, character)

"""
@brief Connects signal handlers for character state changes

@param character The character to bind signals for
"""
func _bind_character_signals(character: Character) -> void:
	character.char_state_changed.connect(func(_value: int): _on_character_changed(character))
	character.char_recruitment_state_changed.connect(func(_value: int): _on_character_changed(character))

"""
@brief Handles character state change events by moving them to appropriate lists

@param character The character whose state has changed
"""
func _on_character_changed(character: Character) -> void:
	print('character changed', character)
	var target_list_name = _get_character_list(character)
	characters.move_item(target_list_name, character)

"""
@brief Determines which list a character should belong to based on their properties

@param character The character to evaluate
@returns String The name of the list the character should be in
"""
func _get_character_list(character: Character) -> String:

	if character.char_state == Enums.CharacterState.DECEASED:
		return LIST_DECEASED
	if character.char_state == Enums.CharacterState.MIA:
		return LIST_MIA
	if character.char_state == Enums.CharacterState.INCARCERATED:
		return LIST_INCARCERATED

	match character.char_recruitment_state:
		Enums.CharacterRecruitmentState.SYMPATHISER_NOT_RECRUITED:
			return LIST_SYMPATHISER_NOT_RECRUITED
		Enums.CharacterRecruitmentState.SYMPATHISER_RECRUITED:
			return LIST_SYMPATHISER_RECRUITED
		Enums.CharacterRecruitmentState.NON_SYMPATHISER_UNKNOWN:
			return LIST_NON_SYMPATHISER_UNKNOWN
		Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN:
			return LIST_NON_SYMPATHISER_KNOWN
		_:
			push_error("Unknown character recruitment state: ", character.char_recruitment_state)
			return ""

#|==============================|
#|     POI Management          |
#|==============================|

"""
@brief Adds a POI to the all POIs list

@param poi The POI to add to the registry
"""
func add_poi(poi: PointOfInterest) -> void:
	pois.add_item(LIST_ALL_POIS, poi)
