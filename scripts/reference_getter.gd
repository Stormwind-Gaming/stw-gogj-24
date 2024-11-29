extends NodeWithCleanup

#|==============================|
#|     			 Getters				    |
#|==============================|
"""
@brief Get the Main node
"""
func map_node() -> GameController:
	var map_scene = get_tree().root.get_node("Main")
	if not map_scene:
		return null
	return get_tree().root.get_node("Main")

"""
@brief Get the game controller singleton
"""
func game_controller() -> GameController:
	var map_scene = get_tree().root.get_node("Main")
	if not map_scene:
		return null
	# LogDuck.d("Map: Getting game controller", {"game_controller": get_tree().root.get_node("Main").game_controller})
	return get_tree().root.get_node("Main").game_controller

"""
@brief Get the global registry singleton
"""
func global_registry() -> GlobalRegistry:
	var map_scene = get_tree().root.get_node("Main")
	if not map_scene:
		return null
	# LogDuck.d("Map: Getting global registry", {"global_registry": get_tree().root.get_node("Main").global_registry})
	return get_tree().root.get_node("Main").global_registry
