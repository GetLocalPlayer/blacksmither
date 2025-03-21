extends FSMState
class_name CombatCharacterState

var _travel_anim: String


func _init(travel_anim: String = "") -> void:
	_travel_anim = travel_anim


func _enter(context: Node) -> void:
	if not _travel_anim.is_empty():
		(context as CombatCharacter).playback.travel(_travel_anim)