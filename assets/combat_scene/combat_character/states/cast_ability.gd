extends FSMState


var _target: CombatCharacter
var _ability: CombatAbility


func _init(target: CombatCharacter) -> void:
	_target = target


func _enter(context: Node) -> void:
	var caster: CombatCharacter = context
	_ability = caster.selected_ability
	caster.playback.travel(caster.selected_ability.animation_travel)
	caster.animation_tree.animation_track_triggered.connect(_on_animation_track_triggered)
	caster.animation_tree.animation_finished.connect(_on_animation_finished)
	_ability = caster.selected_ability
	caster.selected_ability = null


func _exit(context: Node) -> void:
	(context as CombatCharacter).animation_tree.animation_track_triggered.disconnect(_on_animation_track_triggered)
	(context as CombatCharacter).animation_tree.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(_anim_name: StringName) -> void:
	_emit_finished()
	

func _on_animation_track_triggered() -> void:
	_ability.apply(_target)
