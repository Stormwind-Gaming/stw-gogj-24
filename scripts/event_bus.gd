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

"""
@brief Emitted when the game is over
"""
signal game_over()

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
@brief Emitted when a event is created
"""
signal create_new_event_panel(event_type: Enums.EventOutcomeType, characters: Array[Character], poi: PointOfInterest)

"""
@brief Emitted when all windows are closed
"""
signal close_all_windows()

"""
@brief Emitted when a window is closed
"""
signal close_window()

"""
@brief Emitted when a radial menu is closed
"""
signal close_radial_menu()

"""
@brief Emitted when a poi information window is requested
"""
signal open_poi_information(poi: PointOfInterest)

#|==============================|
#|      World-event Management |
#|==============================|
"""
@brief Emitted when a new world-event is created
"""
signal world_event_created(world_event: WorldEvent)

"""
@brief Emitted when a world-event ends
"""
signal world_event_ended(world_event: WorldEvent)

#|==============================|
#|   Endgame Event Management   |
#|==============================|
"""
@brief Emitted when a new endgame step is passed
"""
signal new_endgame_step(endgame_step: Enums.EventOutcomeType)


#|==============================|
#|      Stat Counter		       |
#|==============================|
"""
@brief Emitted when a new stat is created
"""
signal stat_created(stat: String, success: bool)

#|==============================|
#|      Modifier Management    |
#|==============================|
"""
@brief Emitted when a modifier is created
"""
signal modifier_created(modifier: Modifier)

"""
@brief Emitted when a modifier is destroyed
"""
signal modifier_destroyed(modifier: Modifier)
