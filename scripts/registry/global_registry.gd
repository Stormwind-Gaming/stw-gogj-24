extends NodeWithCleanup
class_name GlobalRegistry

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
const LIST_DECEASED = "deceased"
const LIST_ALL_POIS = "all_pois"
const LIST_ALL_DISTRICTS = "all_districts"
const LIST_ALL_ACTIONS = "all_actions"
const LIST_RUMOURS = "rumours"
const LIST_PLANS = "plans"
const LIST_WORLD_EVENTS = "world_events"
const LIST_DISTRICT_MODIFIERS = "district_modifiers"
const LIST_GLOBAL_MODIFIERS = "global_modifiers"

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Registry instance for managing character-related lists
"""
var characters: Registry = Registry.new()

"""
@brief Registry instance for managing POI-related lists
"""
var pois: Registry = Registry.new()

"""
@brief Registry instance for managing district-related lists
"""
var districts: Registry = Registry.new()

"""
@brief Registry instance for managing intel-related lists
"""
var intel: Registry = Registry.new()

"""
@brief Registry instance for managing action-related lists
"""
var actions: Registry = Registry.new()

"""
@brief Registry instance for managing turn-logs lists
"""
var turn_logs: Registry = Registry.new()

"""
@brief Registry instance for managing world-event lists
"""
var world_events: Registry = Registry.new()

"""
@brief Registry instance for managing modifier lists
"""
var modifiers: Registry = Registry.new()

#|==============================|
#|      Initialization         |
#|==============================|
"""
@brief Initializes all registry lists
Creates the necessary lists in each Registry instance
"""
func _init():
	LogDuck.d("Initializing GlobalRegistry")
	
	# Initialize character-related lists
	LogDuck.d("Creating character lists")
	characters.create_list(LIST_SYMPATHISER_RECRUITED)
	characters.create_list(LIST_SYMPATHISER_NOT_RECRUITED)
	characters.create_list(LIST_NON_SYMPATHISER_UNKNOWN)
	characters.create_list(LIST_NON_SYMPATHISER_KNOWN)
	characters.create_list(LIST_DECEASED)
	characters.create_list(LIST_MIA)

	# Initialize other lists with logging
	LogDuck.d("Creating POI lists")
	pois.create_list(LIST_ALL_POIS)

	LogDuck.d("Creating district lists")
	districts.create_list(LIST_ALL_DISTRICTS)

	LogDuck.d("Creating intel lists")
	intel.create_list(LIST_RUMOURS)
	intel.create_list(LIST_PLANS)

	LogDuck.d("Creating action lists")
	actions.create_list(LIST_ALL_ACTIONS)

	LogDuck.d("Creating world event lists")
	world_events.create_list(LIST_WORLD_EVENTS)

	LogDuck.d("Creating modifier lists")
	modifiers.create_list(LIST_DISTRICT_MODIFIERS)
	modifiers.create_list(LIST_GLOBAL_MODIFIERS)

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

	# Modifier events
	EventBus.modifier_created.connect(_on_modifier_created)

"""
@brief Resets all registry lists
"""
func reset() -> void:
	LogDuck.d("Resetting GlobalRegistry")

	# disconnect all signals
	# Character events
	if EventBus.character_created.is_connected(_on_character_created):
		EventBus.character_created.disconnect(_on_character_created)
	if EventBus.character_state_changed.is_connected(_on_character_changed):
		EventBus.character_state_changed.disconnect(_on_character_changed)
	if EventBus.character_recruitment_state_changed.is_connected(_on_character_changed):
		EventBus.character_recruitment_state_changed.disconnect(_on_character_changed)

	# Intel events
	if EventBus.rumour_created.is_connected(_on_rumour_created):
		EventBus.rumour_created.disconnect(_on_rumour_created)
	if EventBus.plan_created.is_connected(_on_plan_created):
		EventBus.plan_created.disconnect(_on_plan_created)
	
	# POI events
	if EventBus.poi_created.is_connected(_on_poi_created):
		EventBus.poi_created.disconnect(_on_poi_created)
	
	# Action events
	if EventBus.action_created.is_connected(_on_action_created):
		EventBus.action_created.disconnect(_on_action_created)
	
	# District events
	if EventBus.district_created.is_connected(_on_district_created):
		EventBus.district_created.disconnect(_on_district_created)
	
	# World-event events
	if EventBus.world_event_created.is_connected(_on_world_event_created):
		EventBus.world_event_created.disconnect(_on_world_event_created)
	
	# Modifier events
	if EventBus.modifier_created.is_connected(_on_modifier_created):
		EventBus.modifier_created.disconnect(_on_modifier_created)
	
	
	# Free all objects before clearing lists
	LogDuck.d("Freeing district objects", {"count": districts.get_all_items().size()})
	for district in districts.get_all_items():
		if is_instance_valid(district):
			district.queue_free()
	
	LogDuck.d("Freeing character objects", {"count": characters.get_all_items().size()})
	for character in characters.get_all_items():
		if is_instance_valid(character):
			character.queue_free()

	LogDuck.d("Freeing POI objects", {"count": pois.get_all_items().size()})
	for poi in pois.get_all_items():
		if is_instance_valid(poi):
			poi.queue_free()
	
	LogDuck.d("Freeing intel objects", {"count": intel.get_all_items().size()})
	for intel_item in intel.get_all_items():
		if is_instance_valid(intel_item):
			intel_item.queue_free()
	
	LogDuck.d("Freeing action objects", {"count": actions.get_all_items().size()})
	for action in actions.get_all_items():
		if is_instance_valid(action):
			action.queue_free()
	
	LogDuck.d("Freeing world event objects", {"count": world_events.get_all_items().size()})
	for world_event in world_events.get_all_items():
		if is_instance_valid(world_event):
			world_event.queue_free()
	
	LogDuck.d("Freeing modifier objects", {"count": modifiers.get_all_items().size()})
	for modifier in modifiers.get_all_items():
		if is_instance_valid(modifier):
			modifier.queue_free()
	
	LogDuck.d("Freeing turn log objects", {"count": turn_logs.get_all_items().size()})
	turn_logs = Registry.new()

	# Clear the lists
	LogDuck.d("Clearing all registry lists")
	characters.clear_all()
	pois.clear_all()
	districts.clear_all()
	intel.clear_all()
	actions.clear_all()
	world_events.clear_all()
	modifiers.clear_all()

#|==============================|
#|     Character Management    |
#|==============================|

"""
@brief Adds a character to the appropriate list based on their properties

@param character The character to add to the registry
"""
func _on_character_created(character: Character) -> void:
	var target_list_name = _get_character_list(character)
	LogDuck.d("Adding character to registry", {
		"character": character.get_full_name(),
		"list": target_list_name
	})
	characters.add_item(target_list_name, character)


"""
@brief Handles character state change events by moving them to appropriate lists

@param character The character whose state has changed
"""
func _on_character_changed(character: Character) -> void:
	if (characters.get_all_items().has(character)):
		var target_list_name = _get_character_list(character)
		LogDuck.d("Moving character to new list", {
			"character": character.get_full_name(),
			"new_list": target_list_name,
			"state": character.char_state,
			"recruitment_state": character.char_recruitment_state
		})
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
	LogDuck.d("Adding POI to registry", {"poi": poi.poi_name})
	pois.add_item(LIST_ALL_POIS, poi)

#|==============================|
#|     Intel Management        |
#|==============================|
"""
@brief Adds a rumour to the rumours list

@param rumour The rumour to add to the registry
"""
func _on_rumour_created(rumour: Rumour) -> void:
	LogDuck.d("Adding rumour to registry", {"text": rumour.rumour_text})
	intel.add_item(LIST_RUMOURS, rumour)

"""
@brief Adds a plan to the plans list

@param plan The plan to add to the registry
"""
func _on_plan_created(plan: Plan) -> void:
	LogDuck.d("Adding plan to registry", {"text": plan.plan_text})
	intel.add_item(LIST_PLANS, plan)

#|==============================|
#|     Action Management      |
#|==============================|
"""
@brief Adds an action to the actions list

@param action The action to add to the registry
"""
func _on_action_created(action: BaseAction) -> void:
	LogDuck.d("Adding action to registry", {"action": action}) # TODO: Add a human identifier to the action, maybe the ActionType?
	actions.add_item(LIST_ALL_ACTIONS, action)

#|==============================|
#|     District Management    |
#|==============================|
"""
@brief Adds a district to the districts list

@param district The district to add to the registry
"""
func _on_district_created(district: District) -> void:
	LogDuck.d("Adding district to registry", {"district": district.district_name})
	districts.add_item(LIST_ALL_DISTRICTS, district)

#|==============================|
#|     World-event Management  |
#|==============================|
"""
@brief Adds a world-event to the world-events list

@param world_event The world-event to add to the registry
"""
func _on_world_event_created(world_event: WorldEvent) -> void:
	LogDuck.d("Adding world event to registry", {"event_text": world_event.event_text})
	world_events.add_item(LIST_WORLD_EVENTS, world_event)

#|==============================|
#|     Modifier Management    |
#|==============================|
"""
@brief Adds a modifier to the modifiers list

@param modifier The modifier to add to the registry
"""
func _on_modifier_created(modifier: Modifier) -> void:
	var list_name = LIST_DISTRICT_MODIFIERS if modifier.scope == Enums.ModifierScope.DISTRICT else LIST_GLOBAL_MODIFIERS
	LogDuck.d("Adding modifier to registry", {
		"name": modifier.modifier_name,
		"scope": modifier.scope,
		"list": list_name
	})
	modifiers.add_item(list_name, modifier)
