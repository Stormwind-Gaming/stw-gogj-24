extends BaseAction

class_name PropagandaAction


func _process_action() -> Array[String]:
	var logs: Array[String] = []

	logs.append("Processing PROPAGANDA action at [u]" + str(poi.poi_name) + "[/u] by " + str(characters))

	return logs
