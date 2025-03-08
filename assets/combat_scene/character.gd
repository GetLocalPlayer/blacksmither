extends Node3D
class_name Character


@export var health: float = 1000:
	get:
		return health
	set(value):
		health = value if value >= 0. else 0.
		if is_node_ready():
			if health == 0.:
				die()


var is_alive: bool:
	get:
		return health > 0


@onready var _playback: AnimationNodeStateMachinePlayback = $Model/AnimationTree.get("parameters/playback")

var _anims: Dictionary = {
	impact = "damaged_impact",
	death = "death",
}


func take_damage(value: float, play_impact_anim: bool = true) -> void:
	health -= value
	if play_impact_anim:
		_playback.travel(_anims.impact)


func die() -> void:
	if health > 0:
		health = 0
	else:
		_playback.travel(_anims.death)