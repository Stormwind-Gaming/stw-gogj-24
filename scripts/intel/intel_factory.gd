extends Object

class_name IntelFactory

# Structure to store each action
class RumourConfig:
	var who_chance: int
	var where_chance: int
	var what_chance: int
	var when_chance: int

	# Constructor for the RumourConfig class
	func _init(who_chance: int, where_chance: int, what_chance: int, when_chance: int):
		self.who_chance = who_chance
		self.where_chance = where_chance
		self.what_chance = what_chance
		self.when_chance = when_chance

		# Calculate the total chances
		var total_chances = self.who_chance + self.where_chance + self.what_chance + self.when_chance
		
		# If the total is not 100, scale the chances proportionally
		if total_chances != 100:
			if total_chances == 0:
				push_error("Error: All chances are zero. Cannot generate a rumour.")
			else:
				# Calculate the scaling factor
				var scale_factor = 100.0 / total_chances
				
				# Scale the chances
				self.who_chance = int(self.who_chance * scale_factor)
				self.where_chance = int(self.where_chance * scale_factor)
				self.what_chance = int(self.what_chance * scale_factor)
				self.when_chance = int(self.when_chance * scale_factor)
				
				print("Scaled chances to 100%: Who: %d, Where: %d, What: %d, When: %d" % 
						[self.who_chance, self.where_chance, self.what_chance, self.when_chance])

static func create_rumour(config: RumourConfig) -> Intel:
	print("Creating rumour...")
	
	var level: Enums.IntelLevel
	var type: Enums.IntelType
	var description: String

	# Generate a random number between 0 and 100
	var random_value = randi() % 100

	# Determine the type of rumour based on the random value and chances
	if random_value < config.who_chance:
		type = Enums.IntelType.WHO
		var rumour_text = Globals.get_rumour_text(type)
		
		var characters = GlobalRegistry.get_all_objects(Enums.Registry_Category.CHARACTER)
		var filtered = []
		for key in characters:
			var value = characters[key]
			if !value.recruited:
				filtered.append(value)
		
		var subject = filtered[randi() % filtered.size()]
		var replacements = {"character": subject.first_name + " " + subject.last_name}
		description = rumour_text.text.format(replacements)
	elif random_value < config.who_chance + config.where_chance:
		type = Enums.IntelType.WHERE
		var rumour_text = Globals.get_rumour_text(type)
		var pois = GlobalRegistry.get_all_objects(Enums.Registry_Category.POI)
		var filtered = []
		for key in pois:
			var value = pois[key]
			filtered.append(value)
		
		var subject = filtered[randi() % filtered.size()]
		var replacements = {"poi": subject.poi_name}
		description = rumour_text.text.format(replacements)
		
		
	elif random_value < config.who_chance + config.where_chance + config.what_chance:
		type = Enums.IntelType.WHAT
		var rumour_text = Globals.get_rumour_text(type)
		description = rumour_text.text
	else:
		type = Enums.IntelType.WHEN
		var rumour_text = Globals.get_rumour_text(type)
		description = rumour_text.text

	print("Rumour created: Type: ", type, ", Description: ", description)
	
	return Intel.new(Enums.IntelLevel.RUMOUR, type, description)

static func combine_rumours(rumours: Array) -> Intel:
		# Verify we have exactly 4 rumours
		if rumours.size() != 4:
				push_error("Need exactly 4 rumours to combine")
				return null
				
		# Check each rumour is unique type and RUMOUR level
		var type_check = {}
		for rumour in rumours:
				if not rumour is Intel or rumour.level != Enums.IntelLevel.RUMOUR:
						push_error("Can only combine RUMOUR level intel")
						return null
				if rumour.type in type_check:
						push_error("Cannot combine duplicate rumour types") 
						return null
				type_check[rumour.type] = true
		
		# Create new PLAN level intel
		var plan = Intel.new(Enums.IntelLevel.PLAN, Enums.IntelType.COMPLETE, "Here is a PLAN")
		
		# Destroy rumours by freeing them
		for rumour in rumours:
				rumour.free()
		
		return plan
