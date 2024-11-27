extends MarginContainer

@export var log_type: Enums.LogType
@export var log_message: String

@onready var log_type_texture_rect = find_child("TextureRect")
@onready var log_message_label = find_child("Label")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match log_type:
		Enums.LogType.WORLD_INFO:
			log_type_texture_rect.texture = load("res://assets/icons/logs/world_info.png")
		Enums.LogType.ACTION_INFO:
			log_type_texture_rect.texture = load("res://assets/icons/logs/action_info.png")
		Enums.LogType.CONSEQUENCE:
			log_type_texture_rect.texture = load("res://assets/icons/logs/consequence.png")
			self.add_theme_constant_override("margin_left", 40)
		Enums.LogType.SUCCESS:
			log_type_texture_rect.texture = load("res://assets/icons/logs/success.png")
			self.add_theme_constant_override("margin_left", 40)
		Enums.LogType.WORLD_EVENT:
			log_type_texture_rect.texture = load("res://assets/icons/logs/world_event.png")
	log_message_label.text = log_message
	log_message_label.meta_clicked.connect(_on_meta_clicked)


"""
@brief Handles meta text clicks
"""
func _on_meta_clicked(meta: String) -> void:
	LogDuck.d("LogList: Meta clicked: %s" % meta)
	
	var split_meta = meta.split(":")

	match split_meta[0]:
		"district":
			var town_details_list_instance = Globals.town_details_list_scene.instantiate()
			EventBus.open_new_window.emit(town_details_list_instance)
			var district = GlobalRegistry.districts.get_item(GlobalRegistry.LIST_ALL_DISTRICTS, int(split_meta[1]))
			EventBus.open_district_window.emit(district)
		"character":
			var character_list_instance = Globals.character_list_scene.instantiate()
			EventBus.open_new_window.emit(character_list_instance)
			var character = GlobalRegistry.characters.get_all_items()[int(split_meta[1])]
			match character.char_state:
				Enums.CharacterState.AVAILABLE:
					LogDuck.e("Character: %s" % character.char_recruitment_state)
					match character.char_recruitment_state:
						Enums.CharacterRecruitmentState.NON_SYMPATHISER_KNOWN:
							LogDuck.e("Character: %s" % character.char_recruitment_state)
							character_list_instance.jump_to_page(1)
						Enums.CharacterRecruitmentState.NON_SYMPATHISER_UNKNOWN:
							character_list_instance.jump_to_page(1)
						_:
							pass
				Enums.CharacterState.ASSIGNED:
					pass
				Enums.CharacterState.ON_MISSION:
					pass
				Enums.CharacterState.MIA:
					character_list_instance.jump_to_page(2)
				Enums.CharacterState.INJURED:
					pass
				Enums.CharacterState.DECEASED:
					character_list_instance.jump_to_page(3)
				_:
					pass
		"poi":
			var town_details_list_instance = Globals.town_details_list_scene.instantiate()
			EventBus.open_new_window.emit(town_details_list_instance)
			var poi = GlobalRegistry.pois.get_item(GlobalRegistry.LIST_ALL_POIS, int(split_meta[1]))
			EventBus.open_poi_window.emit(poi)
		"action":
			EventBus.open_action_window.emit()
		"plan":
			EventBus.open_plan_window.emit(true)
		_:
			pass
