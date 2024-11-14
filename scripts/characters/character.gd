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

var char_knowledge: set = set_char_knowledge, get = get_char_knowledge
var char_status: set = set_char_status, get = get_char_status
var char_role: set = set_char_role, get = get_char_role

#|==============================|
#|           Signals             |
#|==============================|
signal char_knowledge_changed(value: Enums.CharacterKnowledge)
signal char_status_changed(value: Enums.CharacterStatus)
signal char_role_changed(value: Enums.CharacterRole)

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
    char_knowledge = Enums.CharacterKnowledge.NOT_RECRUITED
    char_status = Enums.CharacterStatus.DEFAULT
    char_role = Enums.CharacterRole.DEFAULT

    # Generate stats
    char_charm = MathHelpers.generateBellCurveStat(Constants.CHARACTER_INIT_CHARM_MIN, Constants.CHARACTER_INIT_CHARM_MAX)
    char_subtlety = MathHelpers.generateBellCurveStat(Constants.CHARACTER_INIT_SUBTLETY_MIN, Constants.CHARACTER_INIT_SUBTLETY_MAX)
    char_smarts = MathHelpers.generateBellCurveStat(Constants.CHARACTER_INIT_SMARTS_MIN, Constants.CHARACTER_INIT_SMARTS_MAX)

    # Generate sympathy
    char_sympathy = MathHelpers.generateBellCurveStat(Constants.CHARACTER_INIT_SYMPATHY_MIN, Constants.CHARACTER_INIT_SYMPATHY_MAX)

    # Register the character
    id = GlobalRegistry.register_object(Enums.Registry_Category.CHARACTER, self, char_full_name + '_' + str(char_national_id_number))

#|==============================|
#|        Helper Functions      |
#|==============================|
"""
@brief Retrieves the character's stats in a dictionary format.

@return A dictionary containing the character's subtlety, charm, and smarts.
"""
func get_stats() -> Dictionary:
    return {
        "subtlety": "%02d" % [self.char_subtlety] if self.char_knowledge != Enums.CharacterKnowledge.UNKNOWN else "??",
        "charm": "%02d" % [self.char_charm] if char_knowledge != Enums.CharacterKnowledge.UNKNOWN else "??",
        "smarts": "%02d" % [self.char_smarts] if char_knowledge != Enums.CharacterKnowledge.UNKNOWN else "??",
    }

"""
@brief Sets the character as an agent within the game.

Updates the character's knowledge, status, and role, and notifies the GameController.
"""
func set_agent() -> void:
    # Set the character as an agent
    self.char_knowledge = Enums.CharacterKnowledge.RECRUITED
    self.char_status = Enums.CharacterStatus.DEFAULT
    self.char_role = Enums.CharacterRole.SYMPATHISER

    # TODO: Game controller should listen to these signals and update accordingly
    # Notify the GameController that this character is now an agent
    # GameController.add_agent(self)

"""
@brief Removes the character from being an agent.

Updates the character's knowledge and notifies the GameController to remove all associated actions.
"""
func unset_agent() -> void:
    # Unset the character as an agent
    self.char_knowledge = Enums.CharacterKnowledge.NOT_RECRUITED

    # TODO: Game controller should listen to these signals and update accordingly
    GameController.remove_all_actions_for_character(self)
    # Notify the GameController that this character is no longer an agent
    GameController.remove_agent(self)

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
        self.char_role = Enums.CharacterRole.SYMPATHISER

"""
@brief Retrieves the character's knowledge status.

@return The current knowledge status of the character.
"""
func get_char_knowledge() -> Enums.CharacterKnowledge:
    return char_knowledge

"""
@brief Sets the character's knowledge status and emits a corresponding signal.

@param value The new knowledge status to set.
"""
func set_char_knowledge(value: Enums.CharacterKnowledge) -> void:
    char_knowledge_changed.emit(value)
    char_knowledge = value

"""
@brief Retrieves the character's current status.

@return The current status of the character.
"""
func get_char_status() -> Enums.CharacterStatus:
    return char_status

"""
@brief Sets the character's status and emits a corresponding signal.

@param value The new status to assign to the character.
"""
func set_char_status(value: Enums.CharacterStatus) -> void:
    char_status_changed.emit(value)
    char_status = value

"""
@brief Retrieves the character's role.

@return The current role of the character.
"""
func get_char_role() -> Enums.CharacterRole:
    return char_role

"""
@brief Sets the character's role and emits a corresponding signal.

@param value The new role to assign to the character.
"""
func set_char_role(value: Enums.CharacterRole) -> void:
    char_role_changed.emit(value)
    char_role = value

"""
@brief Constructs the character's full name by combining first and last names.

@return The full name of the character as a string.
"""
func get_full_name() -> String:
    return char_first_name + ' ' + char_last_name