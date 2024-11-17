extends Object

class_name WorldEventFactory

static func randomise_world_event_from_heat(heat: int) -> WorldEvent:
	print("Randomising world event from heat: ", heat)
	
	# Check if any world event should occur based on heat
	var event_chance = MathHelpers.scale_by_progress(
		6.0, # base chance
		heat, # current heat
		1, # min heat
		100, # max heat
		0.5, # min scaling (50% of base at min heat)
		1.5, # max scaling (150% of base at max heat)
		1.0, # minimum allowed chance
		15.0 # maximum allowed chance
	)

	if randf() * 100 < event_chance:
		# Determine event severity based on heat levels
		var event_type: int
		if heat >= Constants.HIGH_HEAT_THRESHOLD: # High heat
			# Random choice between minor (20%), significant (40%), major (40%)
			var roll = randf()
			if roll < Constants.HIGH_HEAT_MINOR_CHANCE:
				event_type = Enums.WorldEventSeverity.MINOR
			elif roll < Constants.HIGH_HEAT_SIGNIFICANT_CHANCE:
				event_type = Enums.WorldEventSeverity.SIGNIFICANT
			else:
				event_type = Enums.WorldEventSeverity.MAJOR
		elif heat >= Constants.MEDIUM_HEAT_THRESHOLD: # Medium heat
			# Random choice between minor (40%) and significant (60%)
			event_type = Enums.WorldEventSeverity.MINOR if randf() < Constants.MEDIUM_HEAT_MINOR_CHANCE else Enums.WorldEventSeverity.SIGNIFICANT
		else: # Low heat
			event_type = Enums.WorldEventSeverity.MINOR
		
		return create_world_event(event_type)
		
	return null

static func create_world_event(severity: Enums.WorldEventSeverity) -> WorldEvent:
	var event = WorldEvent.new(severity)
	event.severity = severity
	return event
