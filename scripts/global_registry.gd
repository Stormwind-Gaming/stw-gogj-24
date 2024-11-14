extends Node

#|==============================|
#|         Overview            |
#|==============================|
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

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief Dictionary storing all registered objects by category
"""
var registered_objects = {}

#|==============================|
#|      Registry Methods       |
#|==============================|
"""
@brief Registers an object in the registry under a specific category

@param category The category to register under
@param obj The object to register
@param object_name Optional name for the object (random if not provided)
@returns String The name used for registration
"""
func register_object(category: Enums.Registry_Category, obj: Object, object_name = null) -> String:
    if category not in registered_objects:
        registered_objects[category] = {}
        
    # Generate a random name if not provided
    if object_name == null:
        object_name = str(randi())  # Generates a random number as a name
    registered_objects[category][object_name] = obj

    return object_name

"""
@brief Retrieves an object from the registry

@param category The category to search in
@param object_name The name of the object to retrieve
@returns Object The retrieved object or null if not found
"""
func get_object(category: Enums.Registry_Category, object_name: String) -> Object:
    return registered_objects.get(category, {}).get(object_name, null)

"""
@brief Retrieves all objects in a category

@param category The category to retrieve
@returns Dictionary Dictionary of all objects in the category
"""
func get_all_objects(category: Enums.Registry_Category) -> Dictionary:
    return registered_objects.get(category, {})

"""
@brief Removes an object from the registry

@param category The category to remove from
@param object_name The name of the object to remove
"""
func unregister_object(category: Enums.Registry_Category, object_name: String) -> void:
    if category in registered_objects:
        registered_objects[category].erase(object_name)
        if registered_objects[category].is_empty():
            registered_objects.erase(category)
