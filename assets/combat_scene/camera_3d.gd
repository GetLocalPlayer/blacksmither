extends Camera3D


var _focused_characters: Array[CombatCharacter] = []


func set_view_on_characters(characters: Array[CombatCharacter]) -> void:
	assert(not characters.is_empty(), "Passed array can't be empty")
	var bounds: AABB = _get_node_aabb(characters[0], false)
	for i: int in range(1, characters.size()):
		bounds = bounds.merge(_get_node_aabb(characters[i], false))
	_fov_to_aabb(bounds)
	global_position.x = bounds.get_center().x
	global_transform = global_transform.looking_at(bounds.get_center())


func focus_view_on_characters(characters: Array[CombatCharacter]) -> void:
	_focused_characters = characters.duplicate()


func clear_focus() -> void:
	_focused_characters.clear()


func _process(_delta: float) -> void:
	if not _focused_characters.is_empty():
		_update_focused_view()


func _update_focused_view() -> void:
	set_view_on_characters(_focused_characters)


func _fov_to_aabb(bounds: AABB) -> void:
	var d: float = bounds.position.distance_to(bounds.end)
	var p1: Vector3 = bounds.get_center() + global_basis.x * d * 0.5
	var p2: Vector3 = p1 - global_basis.x * d 
	var dir1: Vector3 = p1 - global_position
	var dir2: Vector3 = p2 - global_position
	fov = rad_to_deg(dir1.angle_to(dir2))
	

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
