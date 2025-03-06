extends PathFollow3D


# Copies translation and scale from the
# Slot to the children. in global space.
# Chidlren's translation and scale are
# ignored.
# Children are rotated along the path
# over time.

@export_range(0, 10000, 1, "radians_as_degrees") var _rotation_speed: float = 15:
	get:
		return _rotation_speed
	set(value):
		_rotation_speed = value
		if is_node_ready():
			for child in get_children():
				if _remotes.has(child):
					pass
					_remotes[child].update_rotation = value <= 0


@onready var _prev_pos: Vector3 = global_position
var _remotes = {}

func _ready() -> void:
	rotation_mode = RotationMode.ROTATION_Y
	tilt_enabled = false
	cubic_interp = false
	loop = false
	use_model_front = false
	for child in get_children():
		_on_child_entered_tree(child)
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)


func _on_child_entered_tree(child: Node) -> void:
	if child is Node3D:
		child.top_level = true
		var r: RemoteTransform3D = RemoteTransform3D.new()
		add_child(r, false, INTERNAL_MODE_BACK)
		_remotes[child] = r
		r.update_position = true
		r.update_rotation = _rotation_speed <= 0
		r.update_scale = true
		r.use_global_coordinates = true
		r.remote_path = r.get_path_to(child)
		
		
func _on_child_exiting_tree(child: Node) -> void:
	if child is Node3D:
		if _remotes.has(child):
			_remotes[child].queue_free()
			_remotes.erase(child)


func _update_child_facing(child: Node3D, delta: float) -> void:
	var r: RemoteTransform3D = _remotes[child]
	if is_equal_approx(child.global_basis.z.dot(-r.global_basis.z), 1.):
		return
	var a: float = child.global_basis.z.signed_angle_to(-r.global_basis.z, Vector3.UP)
	var delta_a: float = _rotation_speed * delta * sign(a)
	var q: Quaternion = Quaternion(Vector3.UP, a if abs(delta_a) >= abs(a) else delta_a)
	child.global_basis = q * child.global_basis.get_rotation_quaternion()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if _prev_pos.is_equal_approx(global_position):
		return
	for child in get_children():
		if _remotes.has(child) and not _remotes[child].update_rotation:
			_update_child_facing(child, delta)
