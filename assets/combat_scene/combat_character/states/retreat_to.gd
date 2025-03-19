extends FSMState


signal finished


const _ANIM = "retreat"
var _target: Vector3


func _init(target: Vector3) -> void:
	_target = target


func _enter(context: Node) -> void:
	var c: CombatCharacter = context
	c.playback.travel(_ANIM)


func _update(context: Node, delta: float) -> void:
	var c: CombatCharacter = context
	var dir: Vector3 = (_target - c.global_position).normalized()
	var offset: float = c.move_speed * delta
	if c.global_position.distance_squared_to(_target) <= offset**2:
		c.global_position = _target
		finished.emit()
	else:
		c.global_position += dir * offset
		c.global_transform = c.global_transform.looking_at(_target, Vector3.UP, true)