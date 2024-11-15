extends BaseAction

class_name EspionageAction


func _process_action() -> Array[String]:
	var logs: Array[String] = []

	logs.append("Processing ESPIONAGE action at [u]" + str(poi.poi_name) + "[/u] by " + str(characters))

	return logs
