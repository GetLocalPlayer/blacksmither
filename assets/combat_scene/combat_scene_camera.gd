extends Camera3D
class_name CombatSceneCamera


@export var _lerp_rate: float = 0.75
var _focused_characters: Array[CombatCharacter] = []
@onready var _targeted_fov: float = fov
@onready var _targeted_transform: Transform3D = global_transform


func set_view_on_characters(characters: Array[CombatCharacter], instantly: bool = false) -> void:
	assert(not characters.is_empty(), "Passed array can't be empty")
	var c: CombatCharacter = characters[0]
	var bounds: AABB = c.get_aabb(false)
	for i: int in range(characters.size()):
		c = characters[i]
		bounds = bounds.merge(c.get_aabb(false))
	_targeted_transform = global_transform
	_targeted_transform = _targeted_transform.looking_at(bounds.get_center())
	_fov_to_aabb(bounds)
	if instantly:
		fov = _targeted_fov
		global_transform = _targeted_transform


func set_view(_fov: float, _transform: Transform3D) -> void:
	_targeted_fov = _fov
	_targeted_transform = _transform


func focus_view_on_characters(characters: Array[CombatCharacter]) -> void:
	_focused_characters = characters.duplicate()


func clear_focus() -> void:
	_focused_characters.clear()


func _process(delta: float) -> void:
	if not _focused_characters.is_empty():
		set_view_on_characters(_focused_characters)
	var weight: float = delta * _lerp_rate
	if weight > 1: weight = 1
	fov = lerp(fov, _targeted_fov, weight)
	global_transform = global_transform.interpolate_with(_targeted_transform, weight)
	


func _fov_to_aabb(bounds: AABB) -> void:
	var points: Array[Vector3] = [
		bounds.position - bounds.get_center(),
		bounds.end - bounds.get_center(),
		bounds.position + bounds.size * Vector3(1, 0, 0) - bounds.get_center(),
		bounds.position + bounds.size * Vector3(0, 1, 0) - bounds.get_center(),
		bounds.position + bounds.size * Vector3(0, 0, 1) - bounds.get_center(),
		bounds.position + bounds.size * Vector3(1, 1, 0) - bounds.get_center(),
		bounds.position + bounds.size * Vector3(1, 0, 1) - bounds.get_center(),
		bounds.position + bounds.size * Vector3(0, 1, 1) - bounds.get_center(),
	]
	var distances: Array[float] = []
	for p: Vector3 in points:
		distances.append(_targeted_transform.basis.x.dot(p))
	var p1: Vector3 = bounds.get_center() + _targeted_transform.basis.x * distances.min()
	var p2: Vector3 = bounds.get_center() + _targeted_transform.basis.x * distances.max()
	var dir1: Vector3 = p1 - global_position
	var dir2: Vector3 = p2 - global_position
	_targeted_fov = rad_to_deg(dir1.angle_to(dir2))
	