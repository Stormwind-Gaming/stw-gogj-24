extends BaseAction

class_name PlanAction


func _process_action() -> Array[String]:
	var logs: Array[String] = []

	logs.append("Processing PLAN action at [u]" + str(poi.poi_name) + "[/u] by " + str(characters))
	return logs
