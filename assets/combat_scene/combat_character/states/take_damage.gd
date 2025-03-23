extends CombatCharacterState


func _enter(context: Node) -> void:
	super._enter(context)
	var character = context as CombatCharacter
	character.animation_tree.animation_finished.connect(_on_animation_finished)


func _exit(context: Node) -> void:
	super._exit(context)
	(context as CombatCharacter).animation_tree.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(_anim_name: StringName) -> void:
	finished.emit()
