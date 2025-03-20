extends FSMState


const _ANIM_TRAVEL = "take_damage"


func _enter(context: Node) -> void:
	var character = context as CombatCharacter
	character.playback.travel(_ANIM_TRAVEL)
	character.animation_tree.animation_finished.connect(_on_animation_finished)


func _exit(context: Node) -> void:
	(context as CombatCharacter).animation_tree.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(_anim_name: StringName) -> void:
	_emit_finished()
