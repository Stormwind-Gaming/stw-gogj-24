extends Object
class_name WorldEventFactory

static func randomise_world_event_from_heat(heat: int) -> WorldEvent:
	LogDuck.d("Randomising world event from heat", {"heat": heat})
	
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

	LogDuck.d("Calculated event chance", {"chance": event_chance, "heat": heat})

	if randf() * 100 < event_chance:
		LogDuck.d("World event triggered")
		# Determine event severity based on heat levels
		var event_type: int
		if heat >= Constants.HIGH_HEAT_THRESHOLD: # High heat
			var roll = randf()
			LogDuck.d("High heat roll", {"roll": roll})
			if roll < Constants.HIGH_HEAT_MINOR_CHANCE:
				LogDuck.d("Minor event triggered from high heat")
				event_type = Enums.WorldEventSeverity.MINOR
			elif roll < Constants.HIGH_HEAT_SIGNIFICANT_CHANCE:
				LogDuck.d("Significant event triggered from high heat")
				event_type = Enums.WorldEventSeverity.SIGNIFICANT
			else:
				LogDuck.d("Major event triggered from high heat")
				event_type = Enums.WorldEventSeverity.MAJOR
		elif heat >= Constants.MEDIUM_HEAT_THRESHOLD: # Medium heat
			event_type = Enums.WorldEventSeverity.MINOR if randf() < Constants.MEDIUM_HEAT_MINOR_CHANCE else Enums.WorldEventSeverity.SIGNIFICANT
			LogDuck.d("Medium heat event triggered", {"type": event_type})
		else: # Low heat
			LogDuck.d("Low heat minor event triggered")
			event_type = Enums.WorldEventSeverity.MINOR
		
		return create_world_event(event_type)
		
	LogDuck.d("No world event triggered", {"roll": randf() * 100, "required_chance": event_chance})
	return null

static func create_world_event(severity: Enums.WorldEventSeverity) -> WorldEvent:
	LogDuck.d("Creating world event", {"severity": severity})

	# TODO: Implement the endgame events
	if severity == Enums.WorldEventSeverity.ENDGAME:
		LogDuck.d("Endgame event requested (not implemented)")
		pass

	var event_data = Globals.get_world_event_text(severity)
	# check event text as can return null if no event text found
	if not event_data:
		LogDuck.error("No world event text found", {"severity": severity})
		push_error("No world event text found for severity: ", severity)
		return
	
	LogDuck.d("Event data retrieved", {"event_type": event_data.event_type})
	var event: WorldEvent
	var config: WorldEventConfig = WorldEventConfig.new(event_data)

	match event_data.event_type:
		Enums.WorldEventType.MINOR_INCREASED_PATROLS:
			LogDuck.d("Creating minor increased patrols event")
			event = MinorIncreasedPatrolsEvent.new(config)
		Enums.WorldEventType.MINOR_SECRET_POLICE:
			LogDuck.d("Creating minor secret police event")
			event = MinorSecretPoliceEvent.new(config)
		Enums.WorldEventType.MINOR_AIRBASE:
			LogDuck.d("Creating minor airbase event")
			event = MinorAirbaseEvent.new(config)
		Enums.WorldEventType.MINOR_INFORMER:
			LogDuck.d("Creating minor informer event")
			event = MinorInformerEvent.new(config)
		Enums.WorldEventType.SIGNIFICANT_SYMPATHISER_CAPTURED:
			LogDuck.d("Creating significant sympathiser captured event")
			event = SignificantSympathiserCapturedEvent.new(config)
		Enums.WorldEventType.SIGNIFICANT_WEAPONS_CACHE:
			LogDuck.d("Creating significant weapons cache event")
			event = SignificantWeaponsCacheEvent.new(config)
		Enums.WorldEventType.SIGNIFICANT_MILITARY_SHIP:
			LogDuck.d("Creating significant military ship event")
			event = SignificantMilitaryShipEvent.new(config)
		Enums.WorldEventType.MAJOR_SECRET_POLICE:
			LogDuck.d("Creating major secret police event")
			event = MajorSecretPoliceEvent.new(config)
		Enums.WorldEventType.MAJOR_POLICE_COMMANDER:
			LogDuck.d("Creating major police commander event")
			event = MajorPoliceCommanderEvent.new(config)
		Enums.WorldEventType.MAJOR_SAFEHOUSE_DISCOVERED:
			LogDuck.d("Creating major safehouse discovered event")
			event = MajorSafehouseDiscoveredEvent.new(config)
		_:
			LogDuck.error("Unknown world event type", {"event_type": event_data.event_type})
			push_error("Unknown world event type: ", event_data.event_type)
			return null

	event.event_data = event_data
	event.event_text = event_data.event_text
	event.effect_text = event_data.effect_text

	LogDuck.d("World event created", {
		"type": event_data.event_type,
		"text": event.event_text,
		"effect": event.effect_text
	})

	EventBus.world_event_created.emit(event, config)

	return event
