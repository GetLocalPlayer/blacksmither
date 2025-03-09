extends Marker3D


@onready var _health_bar: ProgressBar = $HealthBar
@onready var _target_mark: Panel = $HealthBar/TargetMark
var _character: Character


func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exited_tree)
	_target_mark.hide()
	if get_child_count() > 0:
		_on_child_entered_tree(get_child(0))
	_health_bar.visible = get_child_count() > 0


func _process(_delta: float) -> void:
	var screen_pos: Vector2 = get_viewport().get_camera_3d().unproject_position(global_position)
	_health_bar.position = screen_pos - _health_bar.pivot_offset
	if _character:
		_health_bar.value = _character.health



func _on_child_entered_tree(child: Node) -> void:
	var c: Character = child as Character
	if c:
		_character = c	
		c.mouse_entered.connect(_on_character_mouse_entered)
		c.mouse_exited.connect(_on_character_mouse_exited)
		c.clicked.connect(_on_character_clicked)
		_health_bar.show()
		_health_bar.max_value = c.max_health
		_health_bar.value = c.health


func _on_child_exited_tree(child: Node) -> void:
	var c: Character = child as Character
	if c and _character == c:
		_character = null
		c.mouse_entered.disconnect(_on_character_mouse_entered)
		c.mouse_exited.disconnect(_on_character_mouse_exited)
		c.clicked.disconnect(_on_character_clicked)
		_health_bar.hide()


func _on_character_mouse_entered() -> void:
	_target_mark.show()


func _on_character_mouse_exited() -> void:
	_target_mark.hide()


func _on_character_clicked() -> void:
	pass
