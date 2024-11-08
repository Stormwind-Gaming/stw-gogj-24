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
		description = "A WHO rumour."
	elif random_value < config.who_chance + config.where_chance:
		type = Enums.IntelType.WHERE
		description = "A WHERE rumour."
	elif random_value < config.who_chance + config.where_chance + config.what_chance:
		type = Enums.IntelType.WHAT
		description = "A WHAT rumour."
	else:
		type = Enums.IntelType.WHEN
		description = "A WHEN rumour."

	print("Rumour created: Type: ", type, ", Description: ", description)
	
	return Intel.new(Enums.IntelLevel.RUMOUR, type, description)

func combine_rumours(rumours: Array):
	print("Combining rumours...")
