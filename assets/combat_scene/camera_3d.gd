extends Camera3D


@export var _lerp_rate: float = 0.75
@export var _accent_factor: float = 0.2
var _focused_characters: Array[CombatCharacter] = []
@onready var _targeted_fov: float = fov
@onready var _targeted_transform: Transform3D = global_transform
var accent_on: CombatCharacter = null


func set_view_on_characters(characters: Array[CombatCharacter], instantly: bool = false) -> void:
	assert(not characters.is_empty(), "Passed array can't be empty")
	var bounds: AABB = _get_node_aabb(characters[0], false)
	for i: int in range(1, characters.size()):
		bounds = bounds.merge(_get_node_aabb(characters[i], false))
	_fov_to_aabb(bounds)
	_targeted_transform = global_transform
	#_targeted_transform.origin.x = bounds.get_center().x
	_targeted_transform = _targeted_transform.looking_at(bounds.get_center())
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
	if accent_on:
		var accented_transform: Transform3D = global_transform.looking_at(_get_node_aabb(accent_on, false).get_center())
		global_transform = global_transform.interpolate_with(accented_transform, _accent_factor)
	


func _fov_to_aabb(bounds: AABB) -> void:
	var p1: Vector3 = bounds.get_center() - global_basis.x * bounds.size.x * 0.5
	var p2: Vector3 = p1 - global_basis.x * bounds.size.x 
	var dir1: Vector3 = p1 - global_position
	var dir2: Vector3 = p2 - global_position
	_targeted_fov = rad_to_deg(dir1.angle_to(dir2))
	

func _get_node_aabb(node: Node, exclude_top_level_transform: bool = true) -> AABB:
	var bounds: AABB = AABB()
	# Do not include children that is queued for deletion
	if node.is_queued_for_deletion():
		return bounds
	# Get the aabb of the visual instance
	if node is VisualInstance3D:
		bounds = node.get_aabb()
	# Recurse through all children
	for child in node.get_children():
		var child_bounds: AABB = _get_node_aabb(child, false)
		if bounds.size == Vector3.ZERO:
			bounds = child_bounds
		else:
			bounds = bounds.merge(child_bounds)
	if node is Node3D and not exclude_top_level_transform:
		bounds = node.transform * bounds
	return bounds
