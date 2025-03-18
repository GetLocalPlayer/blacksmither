extends FSMState


const _ANIM = "idle"


func _enter(context: Node, _args: Dictionary = {}) -> void:
	var c: CombatCharacter = context
	c.playback.travle(_ANIM)