extends Node2D

class_name Character

var first_name: String
var last_name: String

var sympathy: float = 50 # 0-100

func _init(first_name: String, last_name: String):
	
	self.first_name = first_name
	self.last_name = last_name
	
	GlobalRegistry.register_object(GlobalRegistry.Registry_Category.CHARACTER, self, self.first_name + ' ' + self.last_name)

func get_full_name() -> String:
	return first_name + ' ' + last_name
