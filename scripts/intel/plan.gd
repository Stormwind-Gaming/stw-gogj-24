extends BaseIntel

class_name Plan

#|==============================|
#|      Inner Classes          |
#|==============================|
"""
@brief Properties class to hold rumour configuration data
"""
class PlanProperties:
	var plan_name: String
	var plan_text: String
	var plan_duration: int
	var plan_expiry: int
	var plan_subject_character: Character
	var plan_subject_poi: PointOfInterest
	var plan_effect: Enums.IntelEffect
	var is_endgame_plan: bool = false
	var stat_check_type: Enums.StatCheckType


#|==============================|
#|         Properties          |
#|==============================|

"""
@brief The name of the plan
"""
var plan_name: String

"""
@brief The text of the plan
"""
var plan_text: String

"""
@brief The duration of the plan
"""
var plan_duration: int

"""
@brief The expiry of the plan
"""
var plan_expiry: int

"""
@brief The character the plan is about
"""
var plan_subject_character: Character

"""
@brief The POI the plan is about
"""
var plan_subject_poi: PointOfInterest

"""
@brief The effect of the plan
"""
var plan_effect: Enums.IntelEffect

"""
@brief A description of the timing of the plan
"""
var plan_timing: String

"""
@brief Whether the plan is an endgame plan
"""
var is_endgame_plan: bool = false

"""
@brief The statistic check type for the plan
"""
var stat_check_type: Enums.StatCheckType

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the plan is initialized.
Sets up initial values and registers with the global registry.
"""
func _init(properties: PlanProperties):
	super()
	LogDuck.d("Initializing new plan", {
		"name": properties.plan_name,
		"duration": properties.plan_duration,
		"expiry": properties.plan_expiry,
		"character": properties.plan_subject_character.get_full_name() if properties.plan_subject_character else "None",
		"poi": properties.plan_subject_poi.poi_name if properties.plan_subject_poi else "None",
		"effect": properties.plan_effect,
		"is_endgame": properties.is_endgame_plan,
		"stat_check_type": properties.stat_check_type
	})

	# Set properties
	plan_name = properties.plan_name
	plan_text = properties.plan_text
	plan_duration = properties.plan_duration
	plan_expiry = properties.plan_expiry
	plan_subject_character = properties.plan_subject_character
	plan_subject_poi = properties.plan_subject_poi
	plan_effect = properties.plan_effect
	is_endgame_plan = properties.is_endgame_plan
	stat_check_type = properties.stat_check_type

	plan_timing = ReferenceGetter.game_controller().calendar.get_date_string(plan_duration)
	LogDuck.d("Plan timing set", {
		"name": plan_name,
		"timing": plan_timing,
		"duration": plan_duration
	})

	if plan_expiry != -1:
		expires_on_turn = ReferenceGetter.game_controller().turn_number + plan_expiry
		LogDuck.d("Plan expiry set", {
			"name": plan_name,
			"current_turn": ReferenceGetter.game_controller().turn_number,
			"expires_on": expires_on_turn,
			"expiry_duration": plan_expiry
		})

	# Register the object after setting properties
	EventBus.plan_created.emit(self)
	LogDuck.d("Plan creation complete and emitted", {
		"name": plan_name,
		"text_length": plan_text.length()
	})
