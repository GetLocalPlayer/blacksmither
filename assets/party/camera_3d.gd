@tool
extends Camera3D


@export var _follow_offset_ratio: float = 1.
@export var _distance: float = 4.


func _ready() -> void:
	current = true


func _process(delta: float) -> void:
	var new_pos = owner.global_position + global_basis.z * _distance
	global_position = global_position.lerp(new_pos, delta * _follow_offset_ratio)