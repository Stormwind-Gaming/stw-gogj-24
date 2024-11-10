extends Node

enum CharacterGender {
	MALE,
	FEMALE
}

enum CharacterNationality {
	BELGIAN,
	GERMAN
}

enum CharacterStatus {
	NONE,
	SYMPATHISER,
	AVAILABLE,
	ASSIGNED,
	MIA,
	INCARCERATED,
	DEAD
}

enum IntelLevel {
	RUMOUR,
	PLAN,
	STRATEGEM
}

enum IntelType {
	WHOWHAT,
	WHERE,
	WHEN,
	COMPLETE
}

enum StatCheckType {
	SUBTLETY,
	SMARTS,
	CHARM
}

enum ActionType {
	NONE,
	INFO,
	ESPIONAGE,
	ASSASSINATION,
	PROPAGANDA
}

enum DistrictType {
	SHOPPING,
	INDUSTRIAL,
	RESIDENTIAL,
}

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
}

enum Registry_Category {
	CHARACTER,
	DISTRICT,
	POI,
	INTEL,
	ITEM
}

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