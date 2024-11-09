extends Node2D

class_name Character

var id : String
var gender: Enums.CharacterGender
var nationality: Enums.CharacterNationality
var picture : String

var first_name: String
var last_name: String

# Stats
var charm: int
var subtlety: int
var smarts: int

# Hidden stats
var sympathy: int # 1-99 how likely is this character to join the resistance?
var recruited: bool = false

func _init(profile:Dictionary):
	
	self.first_name = profile['first_name']
	self.last_name = profile['last_name']
	self.nationality = profile['nationality']
	self.gender = profile['gender']
	self.picture = profile['image_path']
	
	self.charm = _generateBellCurveStat()
	self.subtlety = _generateBellCurveStat()
	self.smarts = _generateBellCurveStat()
	
	self.sympathy = _generateLinearStat(1,100)
	
	self.id = GlobalRegistry.register_object(Enums.Registry_Category.CHARACTER, self, self.first_name + '_' + self.last_name)

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
