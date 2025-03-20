extends FSMState


const _ANIM_TRAVEL = "idle"


func _enter(context: Node) -> void:
	var c: CombatCharacter = context
	c.playback.travel(_ANIM_TRAVEL)
	
