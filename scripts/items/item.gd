extends Node2D

class_name Item

var id : String
var item_name : String

func _init(profile:Dictionary):
	
	self.item_name = profile['item_name']

	self.id = GlobalRegistry.register_object(Enums.Registry_Category.ITEM, self)

	print("Item created: " + self.item_name + " with id: " + self.id)
