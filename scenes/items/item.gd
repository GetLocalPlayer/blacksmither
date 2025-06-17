extends Node
class_name Item


signal broken()
signal repaired(restored: int)


@export var icon: CompressedTexture2D:
	get = get_icon


@export var model: PackedScene


enum MaterialType {
	BONE,
	STONE,
	IRON,
	BRONZE,
	SILVER,
	ORICHALCUM,
	MITHRIL,
}


var material_type_string: Dictionary = {
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


var quality_type_string: Dictionary = {
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


@export var max_durability: int = 10:
	get = get_max_durability, set = set_max_durability
func get_max_durability() -> int: return max_durability
func set_max_durability(value: int) -> void: max_durability = value	


@export var durability: int:
	get = get_durability, set = set_durability
func get_durability() -> int: return durability
func set_durability(value: int) -> void:
	var restored: int = value - durability
	durability = clamp(value, 0, max_durability)
	if durability == 0:
		broken.emit()
	elif restored > 0:
		repaired.emit(restored)


var attack_power: int = 0:
	get = get_attack_power, set = set_attack_power
func get_attack_power() -> int: return attack_power
func set_attack_power(value: int) -> void: attack_power = value


var ability_power: int = 0:
	get = get_ability_power, set = set_ability_power
func get_ability_power() -> int: return ability_power
func set_ability_power(value: int) -> void: ability_power = value


var health: int = 0:
	get = get_health, set = set_health
func get_health() -> int: return health
func set_health(value: int) -> void: health = value


var defense: int = 0:
	get = get_defense, set = set_defense
func get_defense() -> int: return defense
func set_defense(value: int) -> void: defense = value


var speed: int = 0:
	get = get_speed, set = set_speed
func get_speed() -> int: return speed
func set_speed(value: int) -> void: speed = value


var mana: int = 0:
	get = get_mana, set = set_mana
func get_mana() -> int: return mana
func set_mana(value: int) -> void: mana = value



func is_broken() -> bool:
	return durability <= 0


func get_icon() -> CompressedTexture2D:
	return icon