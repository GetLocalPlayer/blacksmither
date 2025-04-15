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
	if caster.weapon and caster.weapon.durability > 0:
		damage += caster.weapon.attack_power
		caster.weapon.durability -= 1
		progress = caster.weapon.durability as float / caster.weapon.max_durability
	target.take_damage(damage)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var caster: CombatCharacter = owner
	caster.ready.connect(func() -> void:
		if caster.weapon:
			progress = caster.weapon.durability as float / caster.weapon.max_durability
	, CONNECT_ONE_SHOT)
