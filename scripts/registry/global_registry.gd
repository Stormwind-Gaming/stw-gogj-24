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
const LIST_ALL_DISTRICTS = "all_districts"
const LIST_ALL_ACTIONS = "all_actions"
const LIST_RUMOURS = "rumours"
const LIST_PLANS = "plans"
const LIST_WORLD_EVENTS = "world_events"

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

"""
@brief Registry instance for managing action-related lists
"""
var actions : Registry = Registry.new()

"""
@brief Registry instance for managing turn-logs lists
"""
var turn_logs : Registry = Registry.new()

"""
@brief Registry instance for managing world-event lists
"""
var world_events : Registry = Registry.new()

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
	districts.create_list(LIST_ALL_DISTRICTS)

	# Initialize intel-related lists
	intel.create_list(LIST_RUMOURS)
	intel.create_list(LIST_PLANS)

	# Initialize action-related lists
	actions.create_list(LIST_ALL_ACTIONS)

	# Initialize world-event-related lists
	world_events.create_list(LIST_WORLD_EVENTS)


func _ready():
	# Character events
	EventBus.character_created.connect(_on_character_created)
	EventBus.character_state_changed.connect(_on_character_changed)
	EventBus.character_recruitment_state_changed.connect(_on_character_changed)

	# Intel events
	EventBus.rumour_created.connect(_on_rumour_created)
	EventBus.plan_created.connect(_on_plan_created)

	# POI events
	EventBus.poi_created.connect(_on_poi_created)

	# Action events
	EventBus.action_created.connect(_on_action_created)

	# District events
	EventBus.district_created.connect(_on_district_created)	

	# World-event events
	EventBus.world_event_created.connect(_on_world_event_created)

#|==============================|
#|     Character Management    |
#|==============================|

"""
@brief Adds a character to the appropriate list based on their properties

@param character The character to add to the registry
"""
func _on_character_created(character: Character) -> void:
	var target_list_name = _get_character_list(character)
	print('adding character to list', target_list_name)
	characters.add_item(target_list_name, character)


"""
@brief Handles character state change events by moving them to appropriate lists

@param character The character whose state has changed
"""
func _on_character_changed(character: Character) -> void:
	print('character state changed: ', character.char_full_name)
	if(characters.get_all_items().has(character)):
		print('character is in registry')
		var target_list_name = _get_character_list(character)
		print('moving character to list: ', target_list_name)
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
func _on_poi_created(poi: PointOfInterest) -> void:
	pois.add_item(LIST_ALL_POIS, poi)

#|==============================|
#|     Intel Management        |
#|==============================|
"""
@brief Adds a rumour to the rumours list

@param rumour The rumour to add to the registry
"""
func _on_rumour_created(rumour: Rumour) -> void:
	intel.add_item(LIST_RUMOURS, rumour)

"""
@brief Adds a plan to the plans list

@param plan The plan to add to the registry
"""
func _on_plan_created(plan: Plan) -> void:
	intel.add_item(LIST_PLANS, plan)

#|==============================|
#|     Action Management      |
#|==============================|
"""
@brief Adds an action to the actions list

@param action The action to add to the registry
"""
func _on_action_created(action: BaseAction) -> void:
	actions.add_item(LIST_ALL_ACTIONS, action)

#|==============================|
#|     District Management    |
#|==============================|
"""
@brief Adds a district to the districts list

@param district The district to add to the registry
"""
func _on_district_created(district: District) -> void:
	districts.add_item(LIST_ALL_DISTRICTS, district)

#|==============================|
#|     World-event Management  |
#|==============================|
"""
@brief Adds a world-event to the world-events list

@param world_event The world-event to add to the registry
"""
func _on_world_event_created(world_event: WorldEvent) -> void:
	world_events.add_item(LIST_WORLD_EVENTS, world_event)
