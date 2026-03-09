@tool
extends CombatCharacterState


var _equipped_weapon: Weapon
var _ability: CombatAbility


func _enter(_context: Node) -> void:
	super._enter(_context)
	var c: CombatCharacter = _context
	_equipped_weapon = c.get_equipped_weapon()
	_ability = c.selected_ability
	

func _apply() -> bool:
	var caster: CombatCharacter = _ability.owner
	_ability.apply(caster.target)
	caster.selected_ability = null
	return true


func exit(_context: CombatCharacter) -> void:
	_equipped_weapon = null
