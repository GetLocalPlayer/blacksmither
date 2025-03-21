extends CombatCharacterBaseState


func _update(context: Node, delta: float) -> void:
	var c: CombatCharacter = context
	var dir: Vector3 = (c.retreat_position - c.global_position).normalized()
	var offset: float = c.move_speed * delta
	if c.global_position.distance_squared_to(c.retreat_position) <= offset**2:
		c.global_position = c.retreat_position
		finished.emit()
	else:
		c.global_position += dir * offset
		c.global_transform = c.global_transform.looking_at(c.retreat_position, Vector3.UP, true)