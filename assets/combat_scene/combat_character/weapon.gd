extends Node


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


var weapon_type_name: Dictionary = {
	WeaponType.DAGGER: "dagger",
	WeaponType.SWORD: "sword",
	WeaponType.POLEARM: "polearm",
	WeaponType.HAMMER: "hammer",
	WeaponType.BOW: "bow",
	WeaponType.AXE: "axe",
	WeaponType.SCHYTHE: "schythe",
	WeaponType.STAFF: "staff",
}


enum MaterialType {
	BONE,
	STONE,
	IRON,
	BRONZE,
	SILVER,
	ORICHALCUM,
	MITHRIL,
}


var material_type_name: Dictionary = {
	MaterialType.BONE: "bone",
	MaterialType.STONE: "stone",
	MaterialType.IRON: "iron",
	MaterialType.BRONZE: "bronze",
	MaterialType.SILVER: "silver",
	MaterialType.ORICHALCUM: "orichalcum",
	MaterialType.MITHRIL: "mithril",
}


enum QualityType {
	AWFUL,
	DISAPPOINTING,
	FRAGILE,
	UNSUCCESSFUL,
	POOR,
	NORMAL,
	GOOD,
	FIRM,
	GREAT,
	PERFECT,
}


var quality_name: Dictionary = {
	QualityType.AWFUL: "Awfuly made",
	QualityType.DISAPPOINTING: "Disappointing",
	QualityType.FRAGILE: "Fragile",
	QualityType.UNSUCCESSFUL: "Unsuccessful",
	QualityType.POOR: "Poor",
	QualityType.NORMAL: "",
	QualityType.GOOD: "Good",
	QualityType.FIRM: "Firm",
	QualityType.GREAT: "Great",
	QualityType.PERFECT: "Perfect",
}


@export var type: WeaponType = WeaponType.SWORD
@export var quality_type: QualityType = QualityType.NORMAL
@export var material_type: MaterialType = MaterialType.IRON
@export var max_durability: int = 0
@export var durability = max_durability
@export_subgroup("Stats Given")
@export var attack_damage: int = 0
@export var ability_power: int = 0
@export var health: int = 0
@export var defense: int = 0
@export var speed: int = 0
@export var mana: int = 0


func _ready() -> void:
	_init_stats()


func _init_stats() -> void:
	max_durability = int((10 + 5 * (material_type + 1)) * (0.1 * quality_type))
	match type:
		WeaponType.DAGGER:
			attack_damage = int((5 + 3 * (material_type + 1)) * (0.1 * quality_type))
			speed = int((10 + 5 *(material_type + 1)) * (0.1 * quality_type))
		WeaponType.SWORD:
			attack_damage = int((10 + 8 * max(material_type, 1)) * (0.1 * quality_type))
			health = int((5 + 2 * max(material_type, 1)) * (0.1 * quality_type))
		WeaponType.POLEARM:
			attack_damage = int((15 + 15*max(material_type, 1)) * (0.1 * quality_type))
			speed = int((2 + 2 * max( material_type - 1, 1)) * (0.1 * quality_type))
			mana = int((2 + 2 * max(material_type - 1, 1)) * (0.1 * quality_type))
		WeaponType.HAMMER:
			attack_damage = int((5 + 4 * max(material_type, 1)) * (0.1 * quality_type))
			health = int((10 + 10 * max(material_type, 1)) * (0.1 * quality_type))
			defense = int((6 + 6 * max(material_type, 1)) * (0.1 * quality_type))
		WeaponType.BOW:
			attack_damage = int((10 + 8 * max(material_type + 1, 1)) * (0.1 * quality_type))
			speed = int((5 + 2 * max(material_type,1)) * (0.1 * quality_type))        
		WeaponType.AXE:
			attack_damage = int((15 + 5 * max(material_type + 1, 1)) * (0.1 * quality_type))
			speed = int((5 + 3 * max(material_type - 1, 1)) * (0.1 * quality_type))
		WeaponType.SCHYTHE:
			attack_damage = int((10 + 10 * max(material_type + 1, 1)) * (0.1 * quality_type))
			speed = int((10 + 5 * max(material_type - 1, 1)) * (0.1 * quality_type))
			mana = int((5 + 3 * max(material_type - 1, 1)) * (0.1 * quality_type))
		WeaponType.STAFF:
			attack_damage = int((2 + 2 * max(material_type + 1, 1)) * (0.1 * quality_type))
			ability_power = int((10 + 10 * max(material_type - 1, 1)) * (0.1 * quality_type))
			mana = int((10 + 5 * max(material_type - 1, 1)) * (0.1 * quality_type))