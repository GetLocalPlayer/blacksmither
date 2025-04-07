@tool
extends CombatAbility


@export var _no_weapon_icon: CompressedTexture2D = null


func get_icon() -> CompressedTexture2D:
	if Engine.is_editor_hint():
		return super.get_icon()
	return _no_weapon_icon if (owner as CombatCharacter).weapon.durability <= 0 else super.get_icon()


func apply(target: CombatCharacter) -> void:
	var caster: CombatCharacter = owner
	var damage: float = caster.attack_damage
	if caster.weapon.durability > 0:
		damage += caster.weapon.attack_power
		caster.weapon.durability -= 1
	print(caster.character_name)
	target.take_damage(damage)
