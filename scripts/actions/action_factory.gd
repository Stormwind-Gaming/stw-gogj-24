extends ObjectWithCleanup

class_name ActionFactory

class ActionConfig:
	var poi: PointOfInterest
	var characters: Array[Character]
	var action_type: Enums.ActionType
	var additional_info: Dictionary

static func create_action(config: ActionConfig) -> BaseAction:

	if config.additional_info.has("associated_plan") and config.additional_info.associated_plan.is_endgame_plan:
		return EndgameAction.new(config)

	match config.action_type:
		Enums.ActionType.ESPIONAGE:
			return EspionageAction.new(config)
		Enums.ActionType.SURVEILLANCE:
			return SurveillanceAction.new(config)
		Enums.ActionType.PROPAGANDA:
			return PropagandaAction.new(config)
		Enums.ActionType.PLAN:
			return PlanAction.new(config)
		_:
			printerr("Invalid action type: ", config.action_type)
			return null
