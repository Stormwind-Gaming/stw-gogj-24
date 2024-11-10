extends Object

class_name IntelFactory

# Structure to store each action
class RumourConfig:
		var whowhat_chance: int
		var where_chance: int
		var when_chance: int

		# Constructor for the RumourConfig class
		func _init(whowhat_chance: int, where_chance: int, when_chance: int):
				self.whowhat_chance = whowhat_chance
				self.where_chance = where_chance
				self.when_chance = when_chance

				# Calculate the total chances
				var total_chances = self.whowhat_chance + self.where_chance + self.when_chance

				# If the total is not 100, scale the chances proportionally
				if total_chances != 100:
						if total_chances == 0:
								push_error("Error: All chances are zero. Cannot generate a rumour.")
						else:
								# Calculate the scaling factor
								var scale_factor = 100.0 / total_chances

								# Scale the chances
								self.whowhat_chance = int(self.whowhat_chance * scale_factor)
								self.where_chance = int(self.where_chance * scale_factor)
								self.when_chance = int(self.when_chance * scale_factor)

								# Adjust for any rounding errors to ensure total is exactly 100
								var adjusted_total = self.whowhat_chance + self.where_chance + self.when_chance
								if adjusted_total != 100:
										self.whowhat_chance += 100 - adjusted_total

								print("Scaled chances to 100%: WhoWhat: %d, Where: %d, When: %d" % 
												[self.whowhat_chance, self.where_chance, self.when_chance])


static func create_rumour(config: RumourConfig) -> Intel:
		print("Creating rumour...")

		var profile = {
			"level": Enums.IntelLevel.RUMOUR,
		}

		# Generate a random number between 0 and 99
		var random_value = randi() % 100

		# Determine the type of rumour based on the random value and chances
		if random_value < config.whowhat_chance:
				profile['type'] = Enums.IntelType.WHOWHAT
				var rumour_text = Globals.get_rumour_text(profile.type)

				profile['effect'] = [rumour_text.effect]

				# TODO: Rejig this with enums
				if(rumour_text.subject == 'CHARACTER'):
						var characters = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)

						var filtered_characters = []
						for key in characters:
								var value = characters[key]
								if !value.recruited:
										filtered_characters.append(value)

						var subject_character = filtered_characters[randi() % filtered_characters.size()]
						var replacements = {
								"character": subject_character.get_full_name(),
						}

						profile['description'] = rumour_text.text.format(replacements)
						profile['related_character'] = subject_character
				else:
						profile['description'] = rumour_text.text

		elif random_value < config.whowhat_chance + config.where_chance:
				profile['type'] = Enums.IntelType.WHERE
				var rumour_text = Globals.get_rumour_text(profile.type)

				profile['description'] = rumour_text.text
				profile['effect'] = [rumour_text.effect]

				# TODO: Rejig this with enums
				if(rumour_text.subject == 'POI'):
						var pois = GlobalRegistry.get_all_objects(Enums.Registry_Category.POI)

						var filtered_pois = []
						for key in pois:
								var value = pois[key]
								filtered_pois.append(value)

						var subject_poi = filtered_pois[randi() % filtered_pois.size()]
						var replacements = {
								"poi": subject_poi.poi_name,
						}

						profile['description'] = rumour_text.text.format(replacements)
						profile['related_poi'] = subject_poi
				else:
						profile['description'] = rumour_text.text

		else:
				profile['type'] = Enums.IntelType.WHEN

				var rumour_text = Globals.get_rumour_text(profile.type)

				profile['description'] = rumour_text.text
				profile['effect'] = [rumour_text.effect]

				match rumour_text.effect:
						Enums.IntelEffect.D_ONE_E_ONE:
								profile['related_duration'] = 1
								profile['related_expiry'] = 1
						Enums.IntelEffect.D_ONE_E_TWO:
								profile['related_duration'] = 1
								profile['related_expiry'] = 2
						Enums.IntelEffect.D_ONE_E_THREE:
								profile['related_duration'] = 1
								profile['related_expiry'] = 3
						Enums.IntelEffect.D_ONE_E_FOUR:
								profile['related_duration'] = 1
								profile['related_expiry'] = 4
						Enums.IntelEffect.D_TWO_E_ONE:
								profile['related_duration'] = 2
								profile['related_expiry'] = 1
						Enums.IntelEffect.D_TWO_E_TWO:
								profile['related_duration'] = 2
								profile['related_expiry'] = 2
						Enums.IntelEffect.D_TWO_E_THREE:
								profile['related_duration'] = 2
								profile['related_expiry'] = 3
						Enums.IntelEffect.D_TWO_E_FOUR:
								profile['related_duration'] = 2
								profile['related_expiry'] = 4
						Enums.IntelEffect.D_THREE_E_ONE:
								profile['related_duration'] = 3
								profile['related_expiry'] = 1
						Enums.IntelEffect.D_THREE_E_TWO:
								profile['related_duration'] = 3
								profile['related_expiry'] = 2
						Enums.IntelEffect.D_THREE_E_THREE:
								profile['related_duration'] = 3
								profile['related_expiry'] = 3
						Enums.IntelEffect.D_THREE_E_FOUR:
								profile['related_duration'] = 3
								profile['related_expiry'] = 4
						Enums.IntelEffect.D_FOUR_E_ONE:
								profile['related_duration'] = 4
								profile['related_expiry'] = 1
						Enums.IntelEffect.D_FOUR_E_TWO:
								profile['related_duration'] = 4
								profile['related_expiry'] = 2
						Enums.IntelEffect.D_FOUR_E_THREE:
								profile['related_duration'] = 4
								profile['related_expiry'] = 3
						Enums.IntelEffect.D_FOUR_E_FOUR:
								profile['related_duration'] = 4
								profile['related_expiry'] = 4
						# Handle other IntelEffects if necessary
						_:
								profile['related_duration'] = 0
								profile['related_expiry'] = 0


		print("Rumour created: Type: ", profile.type, ", Description: ", profile.description)

		return Intel.new(profile)


static func combine_rumours(rumours: Array) -> Intel:
	
	# Initialize variables to hold related data
	var related_character = null
	var related_poi = null
	var related_duration = 0
	var related_expiry = 0

	var profile = {
		"level": Enums.IntelLevel.PLAN,
		"type": Enums.IntelType.COMPLETE,
	}

	# Verify we have exactly 3 rumours (whowhat, where, when)
	if rumours.size() != 3:
		push_error("Need exactly 3 rumours to combine: WhoWhat, Where, When.")
		return null

	# Check each rumour is unique type and RUMOUR level
	var type_check = {}
	for rumour in rumours:
		if not rumour is Intel or rumour.level != Enums.IntelLevel.RUMOUR:
			push_error("Can only combine RUMOUR level intel.")
			return null
		if rumour.type in type_check:
			push_error("Cannot combine duplicate rumour types.")
			return null
		type_check[rumour.type] = true

	# Ensure all required types are present
	var required_types = [Enums.IntelType.WHOWHAT, Enums.IntelType.WHERE, Enums.IntelType.WHEN]
	for req_type in required_types:
		if req_type not in type_check:
			push_error("Missing required rumour type: %s" % [req_type])
			return null

	# Extract related data from each rumour
	for rumour in rumours:
		match rumour.type:
			Enums.IntelType.WHOWHAT:
				related_character = rumour.related_character
			Enums.IntelType.WHERE:
				related_poi = rumour.related_poi
			Enums.IntelType.WHEN:
				related_duration = rumour.related_duration
				related_expiry = rumour.related_expiry

	# Assign the extracted data to the plan's profile
	profile['description'] = "Plan based on multiple rumours."
	profile['related_character'] = related_character
	profile['related_poi'] = related_poi
	profile['related_duration'] = related_duration
	profile['related_expiry'] = related_expiry

	# Create new PLAN level intel
	var plan = Intel.new(profile)

	# Destroy rumours by freeing them
	for rumour in rumours:
		rumour.free()

	print("Combined rumours into PLAN level intel.")
	return plan
