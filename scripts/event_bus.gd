extends Node

#|==============================|
#|      Turn Management         |
#|==============================|
"""
@brief Emitted when a turn ends
"""
signal end_turn_initiated(num: int)

"""
@brief Emitted when a turn begins processing
"""
signal turn_processing_initiated(num: int)

"""
@brief Emitted when turn processing is complete
"""
signal end_turn_complete(num: int)

#|==============================|
#|      Character Management    |
#|==============================|
"""
@brief Emitted when a new character is created
"""
signal character_created(character: Character)

"""
@brief Emitted when a character's recruitment state changes
"""
signal character_recruitment_state_changed(character: Character)

"""
@brief Emitted when a character's state changes
"""
signal character_state_changed(character: Character)

#|==============================|
#|      Action Management       |
#|==============================|
"""
@brief Emitted when a new action is assigned
"""
signal action_created(action: BaseAction)

#|==============================|
#|      Intel Management        |
#|==============================|
"""
@brief Emitted when a new rumour is created
"""
signal rumour_created(rumour: Rumour)

"""
@brief Emitted when a new plan is created
"""
signal plan_created(plan: Plan)

#|==============================|
#|      POI Management         |
#|==============================|
"""
@brief Emitted when a new POI is created
"""
signal poi_created(poi: PointOfInterest)


#|==============================|
#|      District Management     |
#|==============================|
"""
@brief Emitted when a new district is created
"""
signal district_created(district: District)

"""
@brief Emitted when a district's heat level changes
"""
signal district_heat_changed(district: District, heat: float)