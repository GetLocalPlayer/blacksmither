extends Node3D


## The distance at which following starts
@export var max_distance: float = 2
## The distance at which following stops
@export var min_distance: float = 1.5

@onready var _body: CharacterBody3D = owner
@onready var _curve = Curve3D.new()
var _points: Array[Vector3] = []


func _ready() -> void:
	_points.append(_body.global_position)
	_points.append(_body.global_position - _body.global_basis.z * max_distance * get_child_count())


func _physics_process(_delta: float) -> void:
	var new_pos: Vector3 = _body.global_position
	if is_zero_approx(_points[0].distance_squared_to(new_pos)):
		return
	var dot: float = (new_pos - curr_pos).dot(curr_pos - _curve.get_point_position(1))
	if is_equal_approx(dot, 1.0):
		_curve.set_point_position(0, new_pos)
	else:
		_curve.add_point(new_pos, Vector3.ZERO, Vector3.ZERO, 0)
	
	if get_child_count() > 1:
		var children: Array[Node] = get_children()
		for i: int in range(1, children.size()):
			pass
