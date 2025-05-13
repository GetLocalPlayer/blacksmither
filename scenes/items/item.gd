extends Node
class_name Item


@export var icon: CompressedTexture2D:
	get = get_icon


var broken: bool:
	get = is_broken


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


@export var max_durability: int = 10
@export var durability: int:
	set(value):
		durability = clamp(value, 0, max_durability)


var attack_power: int = 0
var ability_power: int = 0
var health: int = 0
var defense: int = 0
var speed: int = 0
var mana: int = 0


func is_broken() -> bool:
	return durability <= 0


func get_icon() -> CompressedTexture2D:
	return icon