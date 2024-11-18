extends Node

#|==============================|
#|      Game & Turn Management  |
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

"""
@brief Emitted when an endgame is triggered
"""
signal endgame_triggered()

"""
@brief Emitted when the game ends
"""
signal game_ended()

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

"""
@brief Emitted when a character's sympathy changes
"""
signal character_sympathy_changed(character: Character)

#|==============================|
#|      Action Management       |
#|==============================|
"""
@brief Emitted when a new action is assigned
"""
signal action_created(action: BaseAction)

"""
@brief Emitted when an action is destroyed
"""
signal action_destroyed(action: BaseAction)

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

"""
@brief Emitted when a radial option is selected
@param option The type of action selected
"""
signal selected_radial_option(option: Enums.ActionType)

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
signal district_heat_changed(district: District, heat: int)

"""
@brief Emitted when a district becomes focused
"""
signal district_just_focused(district: District)

"""
@brief Emitted when a district is no longer focused
"""
signal district_unfocused(district: District)


#|==============================|
#|      Log Management          |
#|==============================|
"""
@brief Emitted when a new log is created
"""
signal log_created(log: TurnLog)

#|==============================|
#|      Window Management       |
#|==============================|
"""
@brief Emitted when a new window is opened
"""
signal open_new_window(window: Window)

"""
@brief Emitted when a new radial is opened
"""
signal open_new_radial_menu(window: RadialMenu)

"""
@brief Emitted when all windows are closed
"""
signal close_all_windows()

#|==============================|
#|      World-event Management |
#|==============================|
"""
@brief Emitted when a new world-event is created
"""
signal world_event_created(world_event: WorldEvent)





#|==============================|
#|      Stat Counter		       |
#|==============================|
"""
@brief Emitted when a new stat is created
"""
signal stat_created(stat: String, success: bool)