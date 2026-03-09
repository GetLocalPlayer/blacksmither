extends CombatCharacterState


# Сколько времени нужно чтобы персонаж достиг цели.
# В идеале заменить на рутмоушн внутри анимации.
@export var approach_time: float = 0.5


func _enter(context: Node) -> void:
	super._enter(context)
	var c: CombatCharacter = context
	var dir = c.global_position.direction_to(c.target.global_position)
	var dist = c.global_position.distance_to(c.target.global_position) - c.get_radius() - c.target.get_radius()
	var tween = create_tween()
	tween.tween_property(c, "global_position", c.global_position + dir * dist, approach_time)
	tween.tween_callback(_emit_finished)