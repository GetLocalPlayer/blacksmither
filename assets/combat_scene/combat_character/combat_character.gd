extends Node3D
class_name Character


@onready var _abilities: Array[CombatAbility] = Array($Abilities.get_children(), TYPE_OBJECT, "Node", CombatAbility)
@onready var _playback: AnimationNodeStateMachinePlayback = $AnimationPlayer.get("parameters/playback")


@export var max_health: float = 100:
	get:
		return max_health
	set(value):
		max_health = value if value >= 0. else 0.


@export var health: float = 100:
	get:
		return health
	set(value):
		health = value if value >= 0. else 0.
		if is_node_ready():
			_playback.travel(_death_animation)


@export_group("Animations")
@export var _death_animation: String = "death"
@export var _hit_animation: String = "hit"
@export var _prep_attack_animation: String = "prep_attack"
@export var _attack_impact_animation: String = "attack_impact"


func get_abilities() -> Array[CombatAbility]:
	return _abilities
