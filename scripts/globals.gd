extends Node

var town_names = []
var district_names = []

func _ready() -> void:
	# load the town names
	var town_csv = preload("res://data/town_names.csv")
	for town in town_csv.records:
		town_names.append(town["town_name"])
	# load the district names
	var district_csv = preload("res://data/district_names.csv")
	for district in district_csv.records:
		district_names.append(district["district_name"])
	




# func _process_cards() -> Array[Card]:
# 	var cards_csv = preload("res://data/cards.csv")
# 	var processing_cards: Array[Card] = []
# 	# loop over the cards and create a new Card for each row
# 	for card in cards_csv.records:
# 		var new_card = Card.new(
# 			card["card_name"]
# 		)
# 		processing_cards.append(new_card)
# 	return processing_cards
