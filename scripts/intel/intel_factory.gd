extends Object

class_name IntelFactory

const Constants = preload("res://scripts/enums.gd")

static func create_rumour(who_chance: int, where_chance: int, what_chance: int, when_chance: int) -> Intel:
	print("Creating rumour...")
	
	var level: Constants.IntelLevel
	var type: Constants.IntelType
	var description: String
	
	# Calculate the total chances
	var total_chances = who_chance + where_chance + what_chance + when_chance
	
	# If the total is not 100, scale the chances proportionally
	if total_chances != 100:
		if total_chances == 0:
			push_error("Error: All chances are zero. Cannot generate a rumour.")
			return null
			
		# Calculate the scaling factor
		var scale_factor = 100.0 / total_chances
		
		# Scale the chances
		who_chance = int(who_chance * scale_factor)
		where_chance = int(where_chance * scale_factor)
		what_chance = int(what_chance * scale_factor)
		when_chance = int(when_chance * scale_factor)
		
		print("Scaled chances to 100%: Who: %d, Where: %d, What: %d, When: %d" % 
			  [who_chance, where_chance, what_chance, when_chance])

	# Generate a random number between 0 and 100
	var random_value = randi() % 100

	# Determine the type of rumour based on the random value and chances
	if random_value < who_chance:
		type = Constants.IntelType.WHO
		description = "A rumour about who is involved."
	elif random_value < who_chance + where_chance:
		type = Constants.IntelType.WHERE
		description = "A rumour about where it happened."
	elif random_value < who_chance + where_chance + what_chance:
		type = Constants.IntelType.WHAT
		description = "A rumour about what happened."
	else:
		type = Constants.IntelType.WHEN
		description = "A rumour about when it happened."

	print("Rumour created: Type: ", type, ", Description: ", description)
	
	return Intel.new(Constants.IntelLevel.RUMOUR, type, description)

func combine_rumours(rumours:Array):
	print("Combining rumour...")
