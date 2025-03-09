extends Node3D
class_name Character


<<<<<<< Updated upstream
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
=======
@onready var _clicker: StaticBody3D = $Clicker
@onready var _target: Panel = $HealthBar/Target


func _ready() -> void:
    _clicker.input_event.connect(_on_click)
    _target.hide()


func _on_click(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
    pass


func _on_mouse_entered() -> void:
    _target.show()


func _on_mouse_exited() -> void:
    _target.hide()
>>>>>>> Stashed changes
