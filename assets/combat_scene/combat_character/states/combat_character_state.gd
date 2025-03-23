extends FSMState
class_name CombatCharacterState


const _ANIMATION_TREE_PARAM_PATH = "parameters/conditions/state_%s"

var name: String


func _init(state_name: String) -> void:
	name = state_name


func _enter(context: Node) -> void:
	(context as CombatCharacter).animation_tree.set(_ANIMATION_TREE_PARAM_PATH % name, true)



func _exit(context: Node) -> void:
	(context as CombatCharacter).animation_tree.set(_ANIMATION_TREE_PARAM_PATH % name, false)