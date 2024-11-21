extends Node

#|==============================|
#|       Character Enums        |
#|==============================|
"""
@brief Gender options for characters
"""
enum CharacterGender {
	MALE,
	FEMALE
}

"""
@brief Nationality options for characters
"""
enum CharacterNationality {
	BELGIAN,
	GERMAN,
	BRITISH,
	FRENCH
}

"""
@brief Profession options for characters
"""
enum CharacterProfession {
	UNKNOWN
}

"""
@brief Knowledge states for characters
"""
enum CharacterRecruitmentState { # Make sure this is in the correct order so we can use < and > operators on it
	NON_SYMPATHISER_UNKNOWN,
	NON_SYMPATHISER_KNOWN,
	SYMPATHISER_NOT_RECRUITED,
	SYMPATHISER_RECRUITED
}

"""
@brief Status options for characters
"""
enum CharacterState {
	AVAILABLE,
	ASSIGNED,
	ON_MISSION,
	MIA,
	INJURED,
	DECEASED
}

#|==============================|
#|        Stat Check Enums      |
#|==============================|
"""
@brief Types of stat checks that can be performed
"""
enum StatCheckType {
	SUBTLETY,
	SMARTS,
	CHARM
}

#|==============================|
#|        Action Enums          |
#|==============================|
"""
@brief Types of actions that can be performed
"""
enum ActionType {
	NONE,
	INFO,
	ESPIONAGE,
	SURVEILLANCE,
	PROPAGANDA,
	PLAN
}

#|==============================|
#|        District Enums        |
#|==============================|
"""
@brief Types of districts in the game
"""
enum DistrictType {
	PORT,
	INDUSTRIAL,
	RESIDENTIAL,
	CIVIC,
	MILITARY,
}

#|==============================|
#|        POI Enums             |
#|==============================|
"""
@brief Types of Points of Interest
"""
enum POIType {
	NONE,
	GESTAPO_HQ,
	TOWN_HALL,
	PARK,
	POST_OFFICE,
	POLICE_STATION,
	TRAIN_STATION,
	DOCKS,
	BROTHEL,
	SUBMARINE_PEN,
	CATHEDRAL,
	CINEMA,
	GROCER,
	SHOP,
	OFFICE,
	CHURCH,
	PUB,
	CAFE,
	FACTORY,
	WAREHOUSE,
	RESIDENCE,
	RESTAURANT,
	WORKSHOP,
	ANTI_AIR_EMPLACEMENT,
	GESTAPO_POST,
	AIR_BASE,
	GARRISON,
	AMMO_FACTORY,
	FOUNDRY
}

"""
@brief Types of bonuses provided by POIs
"""
enum POIBonusType {
	NONE
}

"""
@brief Skills required for POI interactions
"""
enum POISkillRequired {
	NONE,
	SUBTLETY,
	SMARTS,
	CHARM
}

#|==============================|
#|        Registry Enums        |
#|==============================|
"""
@brief Categories for the global registry system
"""
enum Registry_Category {
	CHARACTER,
	DISTRICT,
	POI,
	INTEL,
	ITEM
}

#|==============================|
#|        Rumour Enums          |
#|==============================|
"""
@brief Types of rumours that can be generated
"""
enum RumourType {
	MISSION,
	LOCATION,
	TIME,
	WILDCARD,
}

"""
@brief Subject types for rumours
"""
enum RumourSubject {
	ANY_CHARACTER,
	NON_SYMPATHISER_CHARACTER,
	SYMPATHISER_CHARACTER,
	MIA_CHARACTER,
	INJURED_CHARACTER,
	ANY_POI,
	NONE
}

#|==============================|
#|        Intel Effect Enums     |
#|==============================|
"""
@brief Types of effects that intel can have
"""
enum IntelEffect {
	BUILD_SYMPATHY,
	BUILD_SYMPATHY_ALL,
	DISCOVER_ALL,
	ADD_AGENT_SLOT,
	RESCUE_AGENT,
	WILDCARD_INTEL,
	REDUCE_HEAT,
	REDUCE_HEAT_ALL,
	REDUCE_DIFFICULTY,
	INCREASE_DIFFICULTY,
	D_ONE_E_ONE,
	D_ONE_E_TWO,
	D_ONE_E_THREE,
	D_ONE_E_FOUR,
	D_TWO_E_ONE,
	D_TWO_E_TWO,
	D_TWO_E_THREE,
	D_TWO_E_FOUR,
	D_THREE_E_ONE,
	D_THREE_E_TWO,
	D_THREE_E_THREE,
	D_THREE_E_FOUR,
	D_FOUR_E_ONE,
	D_FOUR_E_TWO,
	D_FOUR_E_THREE,
	D_FOUR_E_FOUR,
	NONE
}

#|==============================|
#|        Log Enums             |
#|==============================|
"""
@brief Types of logs that can be generated
"""
enum LogType {
	WORLD_INFO, # Information about the world e.g. district heat reduced
	ACTION_INFO, # Information about an action e.g. action in progress
	CONSEQUENCE, # An action consequence e.g. MIA agent
	SUCCESS, # An action success e.g. intel generated
	WORLD_EVENT, # A world event e.g. a random event
}

#|==============================|
#|      Event Enums							|
#|==============================|

"""
@brief Types of events that can occur
"""
enum EventOutcomeType {
	NONE,
	INJURED,
	MIA,
	DECEASED,
	NEW_SYMPATHISER,
	HEAT_BREAKPOINT_MEDIUM,
	HEAT_BREAKPOINT_HIGH,
	EVENT_CIVIC_MILESTONE,
	EVENT_INDUSTRIAL_MILESTONE,
	EVENT_PORT_MILESTONE,
	EVENT_RESIDENTIAL_MILESTONE,
	EVENT_MILITARY_MILESTONE,
	SYMPATHY_BREAKPOINT_LOW,
	SYMPATHY_BREAKPOINT_MEDIUM,
	SYMPATHY_BREAKPOINT_HIGH
}

"""
@brief Severity of world events
"""
enum WorldEventSeverity {
	MINOR,
	SIGNIFICANT,
	MAJOR,
	ENDGAME
}

"""
@brief Types of world events
"""
enum WorldEventType {
	MINOR_INCREASED_PATROLS,
	MINOR_SECRET_POLICE,
	MINOR_AIRBASE,
}
