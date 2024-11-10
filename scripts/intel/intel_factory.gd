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
				else:
						profile['description'] = rumour_text.text

		else:
				profile['type'] = Enums.IntelType.WHEN

				var rumour_text = Globals.get_rumour_text(profile.type)

				profile['description'] = rumour_text.text
				profile['effect'] = [rumour_text.effect]

		print("Rumour created: Type: ", profile.type, ", Description: ", profile.description)

		return Intel.new(profile)


static func combine_rumours(rumours: Array) -> Intel:

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

		# Create new PLAN level intel
		profile['description'] = "Plan based on multiple rumours."
		var plan = Intel.new(profile)

		# Optional: Combine descriptions or add more details to the plan
		# Example:
		# plan.description = "Plan based on:\n" + 
		#     "WhoWhat: " + rumours[0].description + "\n" +
		#     "Where: " + rumours[1].description + "\n" +
		#     "When: " + rumours[2].description

		# Destroy rumours by freeing them
		for rumour in rumours:
				rumour.free()

		print("Combined rumours into PLAN level intel.")

		return plan
