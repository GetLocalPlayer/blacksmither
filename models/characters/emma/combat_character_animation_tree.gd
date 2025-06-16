extends AnimationTree
class_name CombatCharacterAnimationTree


signal apply_ability()


func _emit_apply_ability() -> void:
	apply_ability.emit()

