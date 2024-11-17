extends RefCounted

#|==============================|
#|         Properties           |
#|==============================|
"""
@brief Dictionary storing lists of items.
"""
var _registry: Dictionary = {}

#|==============================|
#|         List Management      |
#|==============================|

"""
@brief Creates a new list with the given name.

@param name The name of the list to create.
"""
func create_list(name: String) -> void:
	if _registry.has(name):
		push_error("List '%s' already exists" % name)
		return
	_registry[name] = []

"""
@brief Adds an item to the specified list.

@param list_name The name of the list to add the item to.
@param item The item to add to the list.
"""
func add_item(list_name: String, item) -> void:
	if not _registry.has(list_name):
		push_error("List '%s' does not exist" % list_name)
		return
	_registry[list_name].append(item)

"""
@brief Moves a specific item to the target list from the source list.

@param target_list_name The name of the list to move the item to.
@param item The item to move.
"""
func move_item(target_list_name: String, item: Object) -> void:
	var source_list_name = ""
	for list_name in _registry.keys():
		if _registry[list_name].has(item):
			source_list_name = list_name
			break
	
	if source_list_name == "":
		push_error("Item does not exist in any source list")
		return
	
	if not _registry.has(target_list_name):
		push_error("Target list '%s' does not exist" % target_list_name)
		return

	_registry[source_list_name].erase(item)
	_registry[target_list_name].append(item)

"""
@brief Retrieves an item from the specified list by index.

@param list_name The name of the list to retrieve the item from.
@param index The index of the item to retrieve.
@returns The item at the specified index, or null if the list does not exist.
"""
func get_item(list_name: String, index: int):
	if not _registry.has(list_name):
		push_error("List '%s' does not exist" % list_name)
		return null
	return _registry[list_name][index]

"""
@brief Retrieves a copy of the specified list.

@param list_name The name of the list to retrieve.
@returns A duplicate of the list, or an empty array if the list does not exist.
"""
func get_list(list_name: String) -> Array:
	if not _registry.has(list_name):
		push_error("List '%s' does not exist" % list_name)
		return []
	return _registry[list_name].duplicate()

"""
@brief Retrieves a random item from any non-empty list.

@returns A random item from a non-empty list, or null if no items exist.
"""
func get_random_item():
	if _registry.is_empty():
		return null
	
	# Get non-empty lists
	var non_empty_lists = []
	for list in _registry.values():
		if not list.is_empty():
			non_empty_lists.append(list)
	
	if non_empty_lists.is_empty():
		return null
	
	var selected_list = non_empty_lists[randi() % non_empty_lists.size()]
	return selected_list[randi() % selected_list.size()]

"""
@brief Retrieves a random item from the specified list.

@param list_name The name of the list to get a random item from.
@returns A random item from the list, or null if the list is empty or doesn't exist.
"""
func get_random_item_from_list(list_name: String):
	if not _registry.has(list_name):
		push_error("List '%s' does not exist" % list_name)
		return null
		
	var list = _registry[list_name]
	if list.is_empty():
		return null
		
	return list[randi() % list.size()]

"""
@brief Retrieves all items from all lists.

@returns An array containing all items from all lists.
"""
func get_all_items() -> Array:
	var all_items = []
	for items in _registry.values():
		all_items.append_array(items)
	return all_items

"""
@brief Retrieves the names of all lists.

@returns An array of list names.
"""
func list_names() -> Array:
	return _registry.keys()

#|==============================|
#|         Item Search          |
#|==============================|

"""
@brief Finds the first item in the specified list that matches the given property and value.

@param list_name The name of the list to search.
@param property The property to check on each item.
@param value The value to match against the property.
@returns The first matching item, or null if no match is found.
"""
func find_item(list_name: String, property: String, value) -> Variant:
	if not _registry.has(list_name):
		push_error("List '%s' does not exist" % list_name)
		return null
	
	for item in _registry[list_name]:
		if item.get(property) == value:
			return item
	return null

"""
@brief Finds all items in the specified list that match the given property and value.

@param list_name The name of the list to search.
@param property The property to check on each item.
@param value The value to match against the property.
@returns An array of all matching items.
"""
func find_all_items(list_name: String, property: String, value) -> Array:
	if not _registry.has(list_name):
		push_error("List '%s' does not exist" % list_name)
		return []
	
	var results = []
	for item in _registry[list_name]:
		if item.get(property) == value:
			results.append(item)
	return results

"""
@brief Finds all items across all lists that match the given property and value.

@param property The property to check on each item.
@param value The value to match against the property.
@returns An array of all matching items from all lists.
"""
func find_items_across_lists(property: String, value) -> Array:
	var results = []
	for list in _registry.values():
		for item in list:
			if item.get(property) == value:
				results.append(item)
	return results

"""
@brief Finds all items in the specified list that satisfy a given condition.

@param list_name The name of the list to search.
@param condition A callable function that returns true for items that satisfy the condition.
@returns An array of all items that satisfy the condition.
"""
func find_items_by_condition(list_name: String, condition: Callable) -> Array:
	if not _registry.has(list_name):
		push_error("List '%s' does not exist" % list_name)
		return []
	
	var results = []
	for item in _registry[list_name]:
		if condition.call(item):
			results.append(item)
	return results

#|==============================|
#|         Item Removal         |
#|==============================|

"""
@brief Removes the specified item from any list it is found in.

@param item The item to remove from the registry.
"""
func remove_item(item) -> void:
	for list in _registry.values():
		var index = list.find(item)
		if index != -1:
			list.remove_at(index)
			return

"""
@brief Removes an entire list from the registry.

@param list_name The name of the list to remove.
"""
func remove_list(list_name: String) -> void:
	if not _registry.has(list_name):
		push_error("List '%s' does not exist" % list_name)
		return
	_registry.erase(list_name)

"""
@brief Clears all items from a specific list.

@param list_name The name of the list to clear.
"""
func clear_list(list_name: String) -> void:
	if not _registry.has(list_name):
		push_error("List '%s' does not exist" % list_name)
		return
	_registry[list_name].clear()

"""
@brief Clears all items from all lists but keeps the list structure.
"""
func clear_all() -> void:
	for list in _registry.values():
		list.clear()

#|==============================|
#|         List Information      |
#|==============================|

"""
@brief Returns the number of items in a specific list.

@param list_name The name of the list to check.
@returns The number of items in the list.
"""
func list_size(list_name: String) -> int:
	if not _registry.has(list_name):
		push_error("List '%s' does not exist" % list_name)
		return 0
	return _registry[list_name].size()

"""
@brief Returns the total number of items across all lists.

@returns The total count of items in all lists.
"""
func total_items() -> int:
	var count = 0
	for list in _registry.values():
		count += list.size()
	return count
