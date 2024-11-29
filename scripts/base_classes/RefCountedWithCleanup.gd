extends RefCounted

class_name RefCountedWithCleanup

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# Disconnect all signals this object is connected to
		for connection in get_incoming_connections():
			connection.signal.disconnect(connection.callable)