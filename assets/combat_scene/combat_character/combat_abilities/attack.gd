@tool
extends CombatAbility


func get_icon() -> CompressedTexture2D:
	if Engine.is_editor_hint():
		return super.get_icon()
	var weapon: Weapon = (owner as CombatCharacter).get_equipped_weapon()
	return super.get_icon() if not weapon else weapon.get_icon()



func apply(target: CombatCharacter) -> void:
	var caster: CombatCharacter = owner
	var damage: float = caster.attack_damage
	var weapon: Weapon = caster.get_equipped_weapon()
	if weapon:
		damage += weapon.attack_power
		weapon.durability -= 1
		progress = weapon.durability as float / weapon.max_durability
	target.take_damage(damage)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var caster: CombatCharacter = owner
	caster.ready.connect(func() -> void:
		var weapon: Weapon = caster.get_equipped_weapon()
		if weapon:
			progress = weapon.durability as float / weapon.max_durability
	, CONNECT_ONE_SHOT)
