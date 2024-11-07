extends Node

"""
GlobalRegistry.gd

This script serves as a global registry for managing objects in the project. 
It allows for the registration, retrieval, and unregistration of objects organised by 
categories. This enables access to game data and shared resources across different 
scenes and scripts.

Usage:
- To register an object: Call `register_object(category, obj, name=null)`.
- To retrieve an object: Call `get_object(category, name)`.
- To retrieve all objects in a category: Call `get_all_objects(category)`.
- To unregister an object: Call `unregister_object(category, name)`.

Functions:
- register_object(category: String, obj: Object, name: String = null) -> String:
	Registers an object under a specified category. If no name is provided, a random name is generated.
	Returns the name used for the object.

- get_object(category: String, name: String) -> Object:
	Retrieves the registered object by its category and name. Returns null if not found.

- get_all_objects(category: String) -> Dictionary:
	Retrieves all objects registered under a specified category.

- unregister_object(category: String, name: String) -> void:
	Unregisters an object by its category and name, removing it from the registry.

Example:
	# Registering a character without a name (random name generated)
	var character_name = GlobalRegistry.register_object("characters", agent_instance)

	# Retrieving the character
	var character = GlobalRegistry.get_object("characters", character_name)

	# Fetching all characters
	var all_characters = GlobalRegistry.get_all_objects("characters")

	# Unregistering the character
	GlobalRegistry.unregister_object("characters", character_name)
"""

enum Registry_Category {
	CHARACTER,
	DISTRICT,
	POI,
	INTEL,
}

var registered_objects = {}

func register_object(category: Registry_Category, obj: Object, object_name = null) -> String:
	if category not in registered_objects:
		registered_objects[category] = {}
		
	# Generate a random name if not provided
	if object_name == null:
		object_name = str(randi())  # Generates a random number as a name
	registered_objects[category][object_name] = obj

	return object_name

func get_object(category: Registry_Category, object_name: String) -> Object:
	return registered_objects.get(category, {}).get(object_name, null)

func get_all_objects(category: Registry_Category) -> Dictionary:
	return registered_objects.get(category, {})

func unregister_object(category: Registry_Category, object_name: String) -> void:
	if category in registered_objects:
		registered_objects[category].erase(object_name)
		if registered_objects[category].empty():
			registered_objects.erase(category)
