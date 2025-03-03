extends Path3D


# This node remembers the main nodes path in range
# of the _start_distance * self.get_children_count to
# implement snake-like party movement.

## The distance at which following starts
@export var _start_distance: float = 2
## The distance at which following stops
@export var _stop_distance: float = 0.5

@onready var _body: CharacterBody3D = owner
@onready var _move_speed: float = (owner as Party).speed
var _moving_slots: Array[PathFollow3D] = []


func _ready() -> void:
	top_level = true
	curve = Curve3D.new()
	curve.bake_interval = 999999 # it must be the max of int, but there's no such constant in godot api yet
	curve.add_point(_body.global_position)
	curve.add_point(_body.global_position)
	for child: PathFollow3D in get_children():
		child.progress = 0.
		child.use_model_front = true


func _physics_process(_delta: float) -> void:
	var new_pos: Vector3 = _body.global_position
	# The end of the curve has to be the path's head
	# otherwise we have to calculate all the offsets
	# of the FollowPath3D's due happening offset
	# when the points added into the beginning.
	var tail: Vector3 = curve.get_point_position(curve.point_count - 1)
	if is_zero_approx(tail.distance_squared_to(new_pos)):
		return
	var tail_tail: Vector3 = curve.get_point_position(curve.point_count - 2)
	if is_equal_approx((new_pos - tail).dot(tail - tail_tail), 1.):
		curve.set_point_position(curve.point_count - 1, new_pos)
	else:
		print(new_pos.distance_to(tail))
		curve.add_point(new_pos)
	if get_child_count() > 0:
		(get_child(0) as PathFollow3D).progress_ratio = 1.
		var length: float = curve.get_baked_length()
		for i: int in range(1, get_child_count()):
			var slot: PathFollow3D = get_child(i)
			if not _moving_slots.has(slot):
				if length - slot.progress > _start_distance * i :
					_moving_slots.append(slot)
			if _moving_slots.has(slot):
				slot.progress += _delta * _move_speed
				if slot.name == "Slot2":
					print(slot.name, ' ', length - slot.progress, ' ', _stop_distance * i)
					print(slot.progress)
					print()
				# if length - slot.progress < _stop_distance * i:
				# 	slot.progress = _stop_distance * i
				# 	_moving_slots.erase(slot)
			
	
