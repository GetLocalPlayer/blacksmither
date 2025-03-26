extends FSMState


var _actions = {
	left = "MoveLeft",
	right = "MoveRight",
	up = "MoveUp",
	down = "MoveDown"
}


var _speed: float
var _rotation_speed: float
var _body: CharacterBody3D
#var _model: Node3D
#var _rotation_tween: Tween


func _init(context: Node) -> void:
	_body = context as CharacterBody3D
	_speed = _body.speed
	_rotation_speed = _body.rotation_speed
	#_model = context.get_node("Model")


func _update(context: Node, _delta: float):
	var dir: Vector3 = Vector3.ZERO
	dir.x -= 1 if Input.is_action_pressed(_actions.left) else 0
	dir.x += 1 if Input.is_action_pressed(_actions.right) else 0
	dir.z -= 1 if Input.is_action_pressed(_actions.up) else 0
	dir.z += 1 if Input.is_action_pressed(_actions.down) else 0
	if is_zero_approx(dir.length_squared()):
		_exit(context)
		finished.emit(context)
		return
	dir = dir.normalized()
	var velocity: Vector3 = dir * context.speed
	_body.velocity = velocity
	_body.move_and_slide()
	# var angle: float = dir.angle_to(_model.basis.z)
	# if not is_zero_approx(angle):
	# 	var new_rotation: Quaternion = _model.transform.looking_at(dir + _model.position, Vector3.UP, true).basis.get_rotation_quaternion()
	# 	if _rotation_tween:_rotation_tween.kill()
	# 	_rotation_tween = context.create_tween()
	# 	_rotation_tween.tween_property(_model, "quaternion", new_rotation, angle/_rotation_speed)
