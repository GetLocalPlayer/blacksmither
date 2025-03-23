extends CombatCharacterState


var _character_detected_callable: Callable


func _enter(context: Node) -> void:
	super._enter(context)
	var c: CombatCharacter = context
	_character_detected_callable = _on_character_detected.bind(c.target)
	c.character_detected.connect(_character_detected_callable)


func _update(context: Node, delta: float) -> void:
	var c: CombatCharacter = context
	c.global_position = c.global_position.move_toward(c.target.global_position, c.move_speed * delta)
	c.global_transform = c.global_transform.looking_at(c.target.global_position, Vector3.UP)


func _exit(context: Node) -> void:
	super._exit(context)
	var c: CombatCharacter = context
	c.character_detected.disconnect(_character_detected_callable)


func _on_character_detected(character: CombatCharacter, target: CombatCharacter) -> void:
	if character == target:
		finished.emit()