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
enum CharacterRecruitmentState {
	SYMPATHISER_NOT_RECRUITED,
	SYMPATHISER_RECRUITED,
	NON_SYMPATHISER_UNKNOWN,
	NON_SYMPATHISER_KNOWN
}

"""
@brief Status options for characters
"""
enum CharacterState { 
	AVAILABLE, 
	ASSIGNED,
	MIA,
	INCARCERATED,
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
	AERODROME,
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
	INCARCERATED_CHARACTER,
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