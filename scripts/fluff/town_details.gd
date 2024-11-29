extends Node
class_name TownDetails

#|==============================|
#|         Properties          |
#|==============================|
"""
@brief The town name
"""
var town_name: String = ""

"""
@brief The town popupation
"""
var popupation: int = 0

"""
@brief The town description
"""
var description: String = ""

"""
@brief The Civic district description
"""
var civic_description: String = ""

"""
@brief The Industrial district description
"""
var industrial_description: String = ""

"""
@brief The Residential district description
"""
var residential_description: String = ""

"""
@brief The Military district description
"""
var military_description: String = ""

"""
@brief The Port district description
"""
var port_description: String = ""


#|==============================|
#|      Lifecycle Methods       |
#|==============================|
"""
@brief Called when the node enters the scene tree
"""
func _ready() -> void:
	town_name = Globals.town_names[randi() % Globals.town_names.size()]
	popupation = randi_range(15000, 50000)
	description = "Nestled along the coast where the river meets the sea, %s thrives as a hub of trade and industry. Its docks echo with the clamor of fishermen and laborers, while warehouses line the riverside, brimming with goods destined for the heart of Europe. Beyond the crowded harbor lies a patchwork of narrow streets and modest homes, shadowed by a towering church spire that watches over the town. Farmlands stretch to the horizon, feeding both the people and the occupiers who have made this town a critical cog in their wartime machine. Beneath its industrious surface, whispers of resistance linger, hidden in plain sight among the market squares and quiet alleys." % town_name
	civic_description = "The Civic District stands as the heart of %s's administration and public life, its broad streets flanked by stately buildings and open squares. The imposing town hall dominates the skyline, its clock tower a silent witness to the comings and goings of officials, occupiers, and wary citizens. Nearby, a grand library and courthouse lend the district an air of authority, while smaller offices bustle with clerks and bureaucrats keeping the town’s wheels turning. By day, the district is a center of order and control; by night, its quiet alleys and empty plazas provide fertile ground for secrets and subversion." % town_name
	industrial_description = "The Industrial District hums with relentless energy, its skyline dominated by towering smokestacks and sprawling factories. The air carries the tang of oil and metal, a constant reminder of %s's lifeblood. Workers shuffle through the streets, shoulders hunched under the weight of their toil, while trains and trucks rumble through to transport goods to the harbor. Among the clamor of machinery and the glow of furnaces, quiet acts of sabotage flicker like embers, a defiant spark against the oppressors who exploit the district’s productivity for their own ends." % town_name
	residential_description = "The Residential District sprawls with rows of modest homes and narrow cobblestone streets, a quieter corner of %s where families seek refuge from the chaos of the outside world. Laundry lines crisscross the alleys, and the smell of bread baking drifts from small kitchens. Children play in the shadows of the spire, while their parents exchange whispers of dissent over garden fences. Despite the hardships of rationing and occupation, the district hums with a sense of quiet resilience, its inhabitants finding small ways to hold onto their normalcy—and their defiance." % town_name
	port_description = "The Port District bustles with life and movement, a labyrinth of docks, warehouses, and taverns that never truly sleeps. Fishing boats and cargo ships alike crowd the harbor, their crews unloading goods under the watchful eyes of guards. The salty air mingles with the sharp scents of fish and tar, while merchants haggle loudly over crates of precious supplies. Beneath the surface, however, the port hides a network of smugglers and informants, its shadowed corners and hidden alleys playing host to those who work to undermine the occupation one crate at a time."
	military_description = "The Military District looms as a grim reminder of %s’s occupation, its high fences and guarded checkpoints cutting it off from the rest of the community. Barracks and armories line its perimeter, while the central command post brims with soldiers, maps, and orders from the front. A parade ground lies eerily empty, save for the occasional march of boots. To the locals, the district is a fortress of fear and power—but for the resistance, it is both a threat to be avoided and a target to be breached." % town_name

#|==============================|
#|      Methods						      |
#|==============================|
"""
@brief Get the description for a district
"""
func get_district_description(district: Enums.DistrictType) -> String:
	match district:
		Enums.DistrictType.CIVIC:
			return civic_description
		Enums.DistrictType.INDUSTRIAL:
			return industrial_description
		Enums.DistrictType.RESIDENTIAL:
			return residential_description
		Enums.DistrictType.MILITARY:
			return military_description
		Enums.DistrictType.PORT:
			return port_description
		_:
			return ""
