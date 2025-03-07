extends Marker3D


@onready var _health_bar: ProgressBar = $HealthBar


func _process(_delta: float) -> void:
	var screen_pos: Vector2 = get_viewport().get_camera_3d().unproject_position(global_position)
	_health_bar.position = screen_pos - _health_bar.pivot_offset
