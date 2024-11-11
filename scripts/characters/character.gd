extends Node2D

class_name Character

var id : String
var gender: Enums.CharacterGender
var nationality: Enums.CharacterNationality
var picture : String

var first_name: String
var last_name: String
var dob: String
var national_id_number: int
var profession: String
var associated_poi: PointOfInterest

# Stats
var charm: int
var subtlety: int
var smarts: int

# Hidden stats
var sympathy: int # 1-99 how likely is this character to join the resistance?
var recruited: bool = false
var known: bool = false
var current_status: Enums.CharacterStatus = Enums.CharacterStatus.NONE

func _init(profile: Dictionary):
	self.first_name = profile['first_name']
	self.last_name = profile['last_name']
	self.nationality = profile['nationality']
	self.gender = profile['gender']
	self.picture = profile['image_path']
	self.national_id_number = profile['national_id_number']
	self.dob = GameController.calendar.get_new_birthdate()
	self.profession = 'unknown'
	
	self.charm = _generateBellCurveStat()
	self.subtlety = _generateBellCurveStat()
	self.smarts = _generateBellCurveStat()
	
	self.sympathy = _generateLinearStat(1,100)

	if self.sympathy > 80:
		self.current_status = Enums.CharacterStatus.SYMPATHISER
		self.known = true
	
	self.id = GlobalRegistry.register_object(Enums.Registry_Category.CHARACTER, self, self.first_name + '_' + self.last_name + '_' + str(self.national_id_number))

func _generateLinearStat(min:int, max:int) -> int:
	return randi() % max + min 
	GlobalRegistry.register_object(Enums.Registry_Category.CHARACTER, self, self.first_name + ' ' + self.last_name)

func _generateBellCurveStat() -> int:
	var total = 0
	for i in range(3):
		total += randi() % 4 + 1
	return total - 2

func get_full_name() -> String:
	return first_name + ' ' + last_name
	
func get_stats() -> Dictionary:
	return {
		"subtlety": self.subtlety if self.known else "??",
		"charm": self.charm if self.known else "??",
		"smarts": self.smarts if self.known else "??",
	}

func set_agent() -> void:
	# Set the character as an agent
	recruited = true
	current_status = Enums.CharacterStatus.AVAILABLE
	known = true
	# tell the game controller that this character is now an agent
	GameController.add_agent(self)

func unset_agent() -> void:
	# Unset the character as an agent
	recruited = false
	GameController.remove_all_actions_for_character(self)
	current_status = Enums.CharacterStatus.SYMPATHISER
	# tell the game controller that this character is no longer an agent
	GameController.remove_agent(self)

func set_known() -> void:
	known = true
