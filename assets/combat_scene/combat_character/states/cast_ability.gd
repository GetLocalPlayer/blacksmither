extends CombatCharacterState


const _ANIMATION_TREE_ABILITY_PARAM_PATH = "parameters/conditions/ability_%s" # % ability.name
var _animation_track_trigger_callable: Callable


func _enter(context: Node) -> void:
	super._enter(context)
	var caster: CombatCharacter = context
	prints(caster.get_equipped_weapon())
	var tree: AnimationTree = caster.model_animation_tree
	tree.set(_ANIMATION_TREE_ABILITY_PARAM_PATH % caster.selected_ability.name, true)	
	_animation_track_trigger_callable = Callable(_on_animation_track_triggered).bind(caster)
	tree.animation_track_triggered.connect(_animation_track_trigger_callable)
	tree.animation_finished.connect(_on_animation_finished)


func _exit(context: Node) -> void:
	super._exit(context)
	var caster: CombatCharacter = context
	var tree: AnimationTree = caster.model_animation_tree
	tree.animation_track_triggered.disconnect(_animation_track_trigger_callable)
	tree.animation_finished.disconnect(_on_animation_finished)
	tree.set(_ANIMATION_TREE_ABILITY_PARAM_PATH % caster.selected_ability.name, false)


func _on_animation_finished(_anim_name: StringName) -> void:
	finished.emit()
	

func _on_animation_track_triggered(caster: CombatCharacter) -> void:
	caster.selected_ability.apply(caster.target)
