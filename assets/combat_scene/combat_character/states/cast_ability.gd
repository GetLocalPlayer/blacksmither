extends CombatCharacterState


# Generic CastAbility state.
# The state relies on animation markers whose
# name start with "cast_ability_apply" using
# tween to call the `apply` method.
const _ANIMATION_TREE_ABILITY_PARAM_PATH = "parameters/conditions/ability_%s" # % ability.name
var _on_apply_ability: Callable
var _on_animation_finished: Callable 


func _enter(context: Node) -> void:
	super._enter(context)
	var caster: CombatCharacter = context
	print(caster)
	var anim_tree: CombatCharacterAnimationTree = caster.model_animation_tree
	anim_tree.set(_ANIMATION_TREE_ABILITY_PARAM_PATH % caster.selected_ability.name, true)
	_on_apply_ability = _apply_ability.bind(caster.selected_ability, caster.target)
	anim_tree.apply_ability.connect(_on_apply_ability)
	_on_animation_finished = Callable(func(_anim_name: String) -> void: finished.emit())
	anim_tree.animation_finished.connect(_on_animation_finished)


func _exit(context: Node) -> void:
	super._exit(context)
	var caster: CombatCharacter = context
	var anim_tree: AnimationTree = caster.model_animation_tree
	anim_tree.animation_finished.disconnect(_on_animation_finished)
	anim_tree.apply_ability.disconnect(_on_apply_ability)
	anim_tree.set(_ANIMATION_TREE_ABILITY_PARAM_PATH % caster.selected_ability.name, false)


func _apply_ability(ability: CombatAbility, target: CombatCharacter) -> void:
	ability.apply(target)
	
