extends FSMState


signal finished

var _target: CombatCharacter
var _ability: CombatAbility


func _init(target: CombatCharacter) -> void:
	_target = target


func _enter(context: Node) -> void:
	var caster: CombatCharacter = context
	_ability = caster.selected_ability
	caster.playback.travel(caster.selected_ability.animation)
	print(caster.playback.get_travel_path())
	caster.animation_tree.animation_finished.connect(_on_animation_finished)
	_ability = caster.selected_ability
	_ability.apply(_target)
	caster.selected_ability = null


func _exit(context: Node) -> void:
	(context as CombatCharacter).animation_tree.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
	if anim_name == _ability.animation:
		finished.emit()
