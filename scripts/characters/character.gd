extends Node2D
class_name Character

#|==============================|
#|        Exported Variables     |
#|==============================|
var id: String

var char_gender: Enums.CharacterGender
var char_nationality: Enums.CharacterNationality
var char_picture: CompressedTexture2D

var char_first_name: String
var char_last_name: String
var char_full_name: get = get_full_name
var char_dob: String
var char_national_id_number: int
var char_profession: Enums.CharacterProfession
var char_associated_poi: PointOfInterest

#|==============================|
#|          Stats Variables      |
#|==============================|
var char_charm: int
var char_subtlety: int
var char_smarts: int

#|==============================|
#|        Hidden Stats Variables |
#|==============================|
var char_sympathy: set = set_char_sympathy  # 1-99 how likely is this character to join the resistance?

var char_recruitment_state: set = set_char_recruitment_state, get = get_char_recruitment_state
var char_state: set = set_char_state, get = get_char_state

#|==============================|
#|        Lifecycle Methods      |
#|==============================|
"""
@brief Initializes the Character instance with the provided profile.

@param profile A dictionary containing the character's profile information.
"""
func _init(profile: Dictionary):

	# Assign profile variables
	char_first_name = profile['first_name']
	char_last_name = profile['last_name']
	char_nationality = profile['nationality']
	char_gender = profile['gender']
	char_picture = profile['image_path']
	char_national_id_number = profile['national_id_number']
	char_dob = GameController.calendar.get_new_birthdate()
	char_profession = Enums.CharacterProfession.UNKNOWN

	# Set default values
	char_recruitment_state = Enums.CharacterRecruitmentState.NON_SYMPATHISER_UNKNOWN
	char_state = Enums.CharacterState.AVAILABLE

	# Generate stats
	char_charm = MathHelpers.generateBellCurveStat(Constants.CHARACTER_INIT_CHARM_MIN, Constants.CHARACTER_INIT_CHARM_MAX)
	char_subtlety = MathHelpers.generateBellCurveStat(Constants.CHARACTER_INIT_SUBTLETY_MIN, Constants.CHARACTER_INIT_SUBTLETY_MAX)
	char_smarts = MathHelpers.generateBellCurveStat(Constants.CHARACTER_INIT_SMARTS_MIN, Constants.CHARACTER_INIT_SMARTS_MAX)

	# Generate sympathy
	char_sympathy = MathHelpers.generateBellCurveStat(Constants.CHARACTER_INIT_SYMPATHY_MIN, Constants.CHARACTER_INIT_SYMPATHY_MAX)

	# Register the character
	EventBus.character_created.emit(self)

func _ready():
	print('character ready')

#|==============================|
#|        Helper Functions      |
#|==============================|
"""
@brief Retrieves the character's stats in a dictionary format.

@return A dictionary containing the character's subtlety, charm, and smarts.
"""
func get_stats() -> Dictionary:
	return {
		"subtlety": "%02d" % [self.char_subtlety] if self.char_recruitment_state != Enums.CharacterRecruitmentState.NON_SYMPATHISER_UNKNOWN else "??",
		"charm": "%02d" % [self.char_charm] if char_recruitment_state != Enums.CharacterRecruitmentState.NON_SYMPATHISER_UNKNOWN else "??",
		"smarts": "%02d" % [self.char_smarts] if char_recruitment_state != Enums.CharacterRecruitmentState.NON_SYMPATHISER_UNKNOWN else "??",
	}


#|==============================|
#|       Getters and Setters    |
#|==============================|
"""
@brief Sets the character's sympathy level.

Updates the character's role based on the sympathy value.
@param sympathy An integer representing the sympathy level (1-99).
"""
func set_char_sympathy(sympathy: int) -> void:
	if sympathy > 80:
		# This character is sympathetic to the resistance
		char_recruitment_state = Enums.CharacterRecruitmentState.SYMPATHISER_NOT_RECRUITED

	char_sympathy = sympathy

"""
@brief Retrieves the character's knowledge status.

@return The current knowledge status of the character.
"""
func get_char_recruitment_state() -> Enums.CharacterRecruitmentState:
	return char_recruitment_state

"""
@brief Sets the character's knowledge status and emits a corresponding signal.

@param value The new knowledge status to set.
"""
func set_char_recruitment_state(value: Enums.CharacterRecruitmentState) -> void:
	char_recruitment_state = value
	EventBus.character_recruitment_state_changed.emit(self)

"""
@brief Retrieves the character's current status.

@return The current status of the character.
"""
func get_char_state() -> Enums.CharacterState:
	return char_state

"""
@brief Sets the character's status and emits a corresponding signal.

@param value The new status to assign to the character.
"""
func set_char_state(value: Enums.CharacterState) -> void:
	char_state = value
	EventBus.character_state_changed.emit(self)

"""
@brief Constructs the character's full name by combining first and last names.

@return The full name of the character as a string.
"""
func get_full_name() -> String:
	return char_first_name + ' ' + char_last_name
