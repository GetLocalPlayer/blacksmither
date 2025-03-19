extends FSMState

signal finished


const _ANIM = "run"
var _target: CombatCharacter


func _init(target: CombatCharacter) -> void:
	_target = target

	
func _enter(context: Node) -> void:
	var c: CombatCharacter = context
	c.playback.travel(_ANIM)


func _update(context: Node, delta: float) -> void:
	var c: CombatCharacter = context
	if c.overlaps_area(_target):
		finished.emit()
		return
	c.global_position = c.global_position.move_toward(_target.global_position, c.move_speed * delta)
	c.global_transform = c.global_transform.looking_at(_target.global_position, Vector3.UP)