extends Node2D

class_name Character

var first_name: String
var last_name: String

func _init(first_name: String, last_name: String):
	
	self.first_name = first_name
	self.last_name = last_name
	
	GlobalRegistry.register_object('characters', self.first_name + ' ' + self.last_name, self)
