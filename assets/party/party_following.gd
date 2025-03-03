extends Path3D


# This node remembers the main nodes path in range
# of the _start_distance * self.get_children_count to
# implement snake-like party movement.

## The distance at which following starts
@export var _start_distance: float = 2.
## The distance at which following stops
@export var _stop_distance: float = 1.

@onready var _body: CharacterBody3D = owner
@onready var _move_speed: float = (owner as Party).speed
var _moving_slots: Array[PathFollow3D] = []


func _ready() -> void:
	top_level = true
	curve = Curve3D.new()
	curve.bake_interval = 999999 # it must be the max of int, but there's no such constant in godot api yet
	curve.add_point(_body.global_position)
	curve.add_point(_body.global_position + (_body.global_basis.z * (_start_distance * get_child_count())))
	for child: PathFollow3D in get_children():
		child.progress_ratio = 0.
		child.use_model_front = false


func _physics_process(_delta: float) -> void:
	var new_pos: Vector3 = _body.global_position
	var head: Vector3 = curve.get_point_position(0)
	var offset: float = 0.
	if not is_zero_approx(head.distance_squared_to(new_pos)):
		var after_head: Vector3 = curve.get_point_position(1)
		if is_equal_approx((new_pos - head).dot(head - after_head), 1.):
			curve.set_point_position(0, new_pos)
		else:
			curve.add_point(new_pos, Vector3.ZERO, Vector3.ZERO, 0)
		offset = new_pos.distance_to(head)


	if get_child_count() > 0:
		(get_child(0) as PathFollow3D).progress_ratio = 0.
		for i: int in range(1, get_child_count()):
			var slot: PathFollow3D = get_child(i)
			var prev_slot: PathFollow3D = get_child(i - 1)
			slot.progress += offset
			if not _moving_slots.has(slot):
				if slot.progress - prev_slot.progress > _start_distance:
					_moving_slots.append(slot)
			if _moving_slots.has(slot):
				slot.progress -= _delta * _move_speed
				if slot.progress - prev_slot.progress <= _stop_distance:
					slot.progress = _stop_distance + prev_slot.progress
					_moving_slots.erase(slot)
			
	
