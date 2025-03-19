extends FSMState


const _ANIM = "idle"


func _enter(context: Node) -> void:
	var c: CombatCharacter = context
	c.playback.travel(_ANIM)
	c.get_node("AnimationTree").animation_finished.connect(func(n: String): print(n))
	
