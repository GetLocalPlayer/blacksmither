extends FSMState


signal finished


const _ANIM = "retreat"
var _target: Vector3


func _enter(context: Node, args: Dictionary = {}) -> void:
	assert(args.has("target") and args.target is Vector3)
	_target = args.target
	var c: CombatCharacter = context
	c.playback.travel(_ANIM)


func _update(context: Node, delta: float) -> void:
	var c: CombatCharacter = context
	c.global_position = c.global_position.move_toward(_target, c._move_speed * delta)
	c.global_transform = c.global_transform.looking_at(_target)
	if c.global_position.is_equal_approx(_target):
		finished.emit()