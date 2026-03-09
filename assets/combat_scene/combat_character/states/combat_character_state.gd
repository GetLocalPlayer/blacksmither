extends FSMState
class_name CombatCharacterState

## Какую ноду использовать в advanced expressions внутри
## AnimationTree, эту ноду, или персонажа. Удобно, если
## текущая нода состояний ни на что не влияет, кроме анимации
## и, при этом, анимацию можно определить исходя из параметров
## самого персонажа, например, кол-ва хп.
@export var _used_in_advance_expression: bool = true
@export var _playback_path: String = "parameters/playback"


func _enter(_context: Node) -> void:
	var c = _context as CombatCharacter
	c.animation_tree.advance_expression_base_node = get_path() if _used_in_advance_expression else c.get_path()
	c.animation_tree.get(_playback_path).travel(name)