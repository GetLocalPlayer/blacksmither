extends Marker3D
class_name CombatSlot


@onready var target_marks: Dictionary = {
	primary = $HealthBar/TargetMarks/Primary,
	secondary = $HealthBar/TargetMarks/Secondary,
}

@onready var _health_bar: ProgressBar = $HealthBar
@onready var _character: CombatCharacter = $Character


func get_character() -> CombatCharacter:
	return _character

		
func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exited_tree)
	if get_child_count() > 0:
		_on_child_entered_tree(get_child(0))
	_health_bar.visible = get_child_count() > 0


func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if camera:
		var screen_pos: Vector2 = get_viewport().get_camera_3d().unproject_position(global_position)
		_health_bar.position = screen_pos - _health_bar.pivot_offset
	if _character:
		_health_bar.value = _character.health


func _on_child_entered_tree(child: Node) -> void:
	var c: CombatCharacter = child as CombatCharacter
	if c:
		_character = c	
		_health_bar.show()
		_health_bar.max_value = c.max_health
		_health_bar.value = c.health


func _on_child_exited_tree(child: Node) -> void:
	var c: CombatCharacter = child as CombatCharacter
	if c and _character == c:
		_character = null
		_health_bar.hide()