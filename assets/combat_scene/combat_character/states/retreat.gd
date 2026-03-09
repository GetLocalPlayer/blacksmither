extends CombatCharacterState


# Сколько времени нужно чтобы персонаж достиг цели.
# В идеале заменить на рутмоушн внутри анимации.
@export var approach_time: float = 0.5


func _enter(context: Node) -> void:
	super._enter(context)
	var c: CombatCharacter = context
	var tween = create_tween()
	tween.tween_property(c, "global_position", c.retreat_position, approach_time)
	tween.tween_callback(c.retreated.emit)
	tween.tween_callback(_emit_finished)
