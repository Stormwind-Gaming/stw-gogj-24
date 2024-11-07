extends Node2D

class_name Character

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

func _init(profile:Dictionary):
	
	self.first_name = profile['first_name']
	self.last_name = profile['last_name']
	self.nationality = profile['nationality']
	self.gender = profile['gender']
	self.picture = profile['image_path']
	
	self.charm = _generateStat(1,10)
	self.subtlety = _generateStat(1,10)
	self.smarts = _generateStat(1,10)
	
	self.sympathy = _generateStat(1,100)
	
	GlobalRegistry.register_object('characters', self, self.first_name + '_' + self.last_name)

func _generateStat(min:int, max:int) -> int:
	return randi() % max + min 
