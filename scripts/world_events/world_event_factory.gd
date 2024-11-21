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

	event_chance = 100

	if randf() * 100 < event_chance:
		print("World event triggered")
		# Determine event severity based on heat levels
		var event_type: int
		if heat >= Constants.HIGH_HEAT_THRESHOLD: # High heat
			# Random choice between minor (20%), significant (40%), major (40%)
			var roll = randf()
			if roll < Constants.HIGH_HEAT_MINOR_CHANCE:
				print("Minor event triggered")
				event_type = Enums.WorldEventSeverity.MINOR
			elif roll < Constants.HIGH_HEAT_SIGNIFICANT_CHANCE:
				print("Significant event triggered")
				event_type = Enums.WorldEventSeverity.SIGNIFICANT
			else:
				print("Major event triggered")
				event_type = Enums.WorldEventSeverity.MAJOR
		elif heat >= Constants.MEDIUM_HEAT_THRESHOLD: # Medium heat
			# Random choice between minor (40%) and significant (60%)
			event_type = Enums.WorldEventSeverity.MINOR if randf() < Constants.MEDIUM_HEAT_MINOR_CHANCE else Enums.WorldEventSeverity.SIGNIFICANT
			print("Medium event triggered")
		else: # Low heat
			print("Minor event triggered")
			event_type = Enums.WorldEventSeverity.MINOR
		
		return create_world_event(event_type)
		
	return null

static func create_world_event(severity: Enums.WorldEventSeverity) -> WorldEvent:

	print("Creating world event with severity: ", severity)

	# TODO: Implement the endgame events
	if severity == Enums.WorldEventSeverity.ENDGAME:
		pass

	var event_text = Globals.get_world_event_text(severity)
	var event: WorldEvent
	var config: WorldEventConfig = WorldEventConfig.new(event_text)

	match event_text.event_type:
		Enums.WorldEventType.MINOR_INCREASED_PATROLS:
			print("Creating minor increased patrols event")
			event = MinorIncreasedPatrolsEvent.new(config)
		Enums.WorldEventType.MINOR_SECRET_POLICE:
			print("Creating minor secret police event")
			event = MinorSecretPoliceEvent.new(config)
		Enums.WorldEventType.MINOR_AIRBASE:
			print("Creating minor airbase event")
			event = MinorAirbaseEvent.new(config)
		_:
			push_error("Unknown world event type: ", event_text.event_type)
			return null

	event.event_text = event_text.event_text
	event.effect_text = event_text.effect_text

	return event
