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


func _ready() -> void:
	_init_stats()


func _init_stats() -> void:
	max_durability = int((10 + 5 * (material_type + 1)) * (0.1 * quality_type))
	match type:
		WeaponType.DAGGER:
			attack_power = int((5 + 3 * (material_type + 1)) * (0.1 * quality_type))
			speed = int((10 + 5 *(material_type + 1)) * (0.1 * quality_type))
		WeaponType.SWORD:
			attack_power = int((10 + 8 * max(material_type, 1)) * (0.1 * quality_type))
			health = int((5 + 2 * max(material_type, 1)) * (0.1 * quality_type))
		WeaponType.POLEARM:
			attack_power = int((15 + 15*max(material_type, 1)) * (0.1 * quality_type))
			speed = int((2 + 2 * max( material_type - 1, 1)) * (0.1 * quality_type))
			mana = int((2 + 2 * max(material_type - 1, 1)) * (0.1 * quality_type))
		WeaponType.HAMMER:
			attack_power = int((5 + 4 * max(material_type, 1)) * (0.1 * quality_type))
			health = int((10 + 10 * max(material_type, 1)) * (0.1 * quality_type))
			defense = int((6 + 6 * max(material_type, 1)) * (0.1 * quality_type))
		WeaponType.BOW:
			attack_power = int((10 + 8 * max(material_type + 1, 1)) * (0.1 * quality_type))
			speed = int((5 + 2 * max(material_type,1)) * (0.1 * quality_type))        
		WeaponType.AXE:
			attack_power = int((15 + 5 * max(material_type + 1, 1)) * (0.1 * quality_type))
			speed = int((5 + 3 * max(material_type - 1, 1)) * (0.1 * quality_type))
		WeaponType.SCHYTHE:
			attack_power = int((10 + 10 * max(material_type + 1, 1)) * (0.1 * quality_type))
			speed = int((10 + 5 * max(material_type - 1, 1)) * (0.1 * quality_type))
			mana = int((5 + 3 * max(material_type - 1, 1)) * (0.1 * quality_type))
		WeaponType.STAFF:
			attack_power = int((2 + 2 * max(material_type + 1, 1)) * (0.1 * quality_type))
			ability_power = int((10 + 10 * max(material_type - 1, 1)) * (0.1 * quality_type))
			mana = int((10 + 5 * max(material_type - 1, 1)) * (0.1 * quality_type))