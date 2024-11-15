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

#|==============================|
#|      Lifecycle Methods      |
#|==============================|
"""
@brief Called when the plan is initialized.
Sets up initial values and registers with the global registry.
"""
func _init(properties: PlanProperties):
	super()
	print('Plan init')

	# Set properties
	plan_name = properties.plan_name
	plan_text = properties.plan_text
	plan_duration = properties.plan_duration
	plan_expiry = properties.plan_expiry
	plan_subject_character = properties.plan_subject_character
	plan_subject_poi = properties.plan_subject_poi
	plan_effect = properties.plan_effect

	plan_timing = GameController.calendar.get_date_string(plan_duration)

	expires_on_turn = GameController.turn_number + plan_expiry

	# Register the object after setting properties
	EventBus.plan_created.emit(self)
	