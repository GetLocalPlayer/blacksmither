extends CombatCharacterBaseState


const _ANIM_TRAVEL = "run"
var _target: CombatCharacter


func _init(target: CombatCharacter) -> void:
	_target = target

	
func _enter(context: Node) -> void:
	var c: CombatCharacter = context
	c.playback.travel(_ANIM_TRAVEL)
	c.character_detected.connect(_on_character_detected)


func _update(context: Node, delta: float) -> void:
	var c: CombatCharacter = context
	c.global_position = c.global_position.move_toward(_target.global_position, c.move_speed * delta)
	c.global_transform = c.global_transform.looking_at(_target.global_position, Vector3.UP)


func _exit(context: Node) -> void:
	var c: CombatCharacter = context
	c.character_detected.disconnect(_on_character_detected)


func _on_character_detected(character: CombatCharacter) -> void:
	print(character)
	if character == _target:
		finished.emit()