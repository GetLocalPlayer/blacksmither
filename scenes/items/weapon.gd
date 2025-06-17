@tool
extends Item
class_name Weapon


enum WeaponType {
	DAGGER,
	SWORD,
	POLEARM,
	HAMMER,
	BOW,
	AXE,
	SCHYTHE,
	STAFF,
}

enum AttackType {
	MELEE,
	RANGED,
}


var weapon_type_string: Dictionary = {
	WeaponType.DAGGER: "dagger",
	WeaponType.SWORD: "sword",
	WeaponType.POLEARM: "polearm",
	WeaponType.HAMMER: "hammer",
	WeaponType.BOW: "bow",
	WeaponType.AXE: "axe",
	WeaponType.SCHYTHE: "schythe",
	WeaponType.STAFF: "staff",
}


@export var type: WeaponType = WeaponType.SWORD
@export var quality_type: QualityType = QualityType.NORMAL
@export var material_type: MaterialType = MaterialType.IRON
@export var ranged: AttackType = AttackType.MELEE


func get_max_durability() -> int:
	var result: int = int((10 + 5 * (material_type + 1) * (0.1 * quality_type)))
	return clamp(result, 1, result)


func get_attack_power() -> int:
	match type:
		WeaponType.DAGGER:
			return int((5 + 3 * (material_type + 1)) * (0.1 * quality_type))
		WeaponType.SWORD:
			return int((10 + 8 * max(material_type, 1)) * (0.1 * quality_type))
		WeaponType.POLEARM:
			return int((15 + 15 * max(material_type, 1)) * (0.1 * quality_type))
		WeaponType.HAMMER:
			return int((5 + 4 * max(material_type, 1)) * (0.1 * quality_type))
		WeaponType.BOW:
			return int((10 + 8 * max(material_type + 1, 1)) * (0.1 * quality_type))
		WeaponType.AXE:
			return int((15 + 5 * max(material_type + 1, 1)) * (0.1 * quality_type))
		WeaponType.SCHYTHE:
			return int((10 + 10 * max(material_type + 1, 1)) * (0.1 * quality_type))
		WeaponType.STAFF:
			return int((2 + 2 * max(material_type + 1, 1)) * (0.1 * quality_type))
	return attack_power


func get_speed() -> int:
	match type:
		WeaponType.DAGGER:
			return int((10 + 5 *(material_type + 1)) * (0.1 * quality_type))
		WeaponType.POLEARM:
			return int((2 + 2 * max( material_type - 1, 1)) * (0.1 * quality_type))
		WeaponType.BOW:
			return int((5 + 2 * max(material_type,1)) * (0.1 * quality_type))        
		WeaponType.AXE:
			return int((5 + 3 * max(material_type - 1, 1)) * (0.1 * quality_type))
		WeaponType.SCHYTHE:
			return int((10 + 5 * max(material_type - 1, 1)) * (0.1 * quality_type))
	return speed



func get_defense() -> int:
	match type:
		WeaponType.HAMMER:
			return int((6 + 6 * max(material_type, 1)) * (0.1 * quality_type))
	return defense


func get_health() -> int:
	match type:
		WeaponType.SWORD:
			return int((5 + 2 * max(material_type, 1)) * (0.1 * quality_type))
		WeaponType.HAMMER:
			return int((10 + 10 * max(material_type, 1)) * (0.1 * quality_type))
	return health


func get_mana() -> int:
	match type:
		WeaponType.POLEARM:
			return int((2 + 2 * max(material_type - 1, 1)) * (0.1 * quality_type))
		WeaponType.SCHYTHE:
			return int((5 + 3 * max(material_type - 1, 1)) * (0.1 * quality_type))
		WeaponType.STAFF:
			return int((10 + 5 * max(material_type - 1, 1)) * (0.1 * quality_type))
	return mana