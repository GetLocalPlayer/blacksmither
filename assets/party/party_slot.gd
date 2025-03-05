extends PathFollow3D


# Copies translation and scale from the
# Slot to the children. in global space.
# Chidlren's translation and scale are
# ignored.
# Children are rotated along the path
# over time.

@export_range(0, 10000, 1, "radians_as_degrees") var _rotation_speed: float = 15.

@onready var _prev_pos: Vector3 = global_position


func _ready() -> void:
	var on_child_entered_tree = func(child: Node):
		if child is Node3D:
			_update_child_transform(child, 0)
			child.top_level = true

	get_parent().child_entered_tree.connect(on_child_entered_tree)

	for child in get_children():
		on_child_entered_tree.call(child)


func _update_child_transform(child: Node3D, delta: float) -> void:
	var s: Basis = Basis.from_scale(global_basis.get_scale())
	var r: Basis
	var o: Vector3 = global_position
	var pos_delta = global_position - _prev_pos
	_prev_pos = global_position
	pos_delta.y = 0.
	var delta_dir = pos_delta.normalized()
	if _rotation_speed > 0:
		var a = delta_dir.angle_to(child.global_basis.z)
		var delta_a = _rotation_speed * delta
		r = child.global_basis * Quaternion(Vector3.UP, a if delta_a >= a else delta_a)
	else:
		r = Basis.looking_at(delta_dir, Vector3.UP, true)
	#child.global_transform = Transform3D(r * s, o)
	child.global_transform = Transform3D(r, o)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_zero_approx(_prev_pos.distance_squared_to(global_position)):
		return
	for child in get_children():
		if child is Node3D:
			_update_child_transform(child, delta)
