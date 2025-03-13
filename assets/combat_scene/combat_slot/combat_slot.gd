extends Marker3D
class_name CombatSlot


signal mouse_entered(slot: CombatSlot, character: CombatCharacter)
signal mouse_exited(slot: CombatSlot, character: CombatCharacter)
signal mouse_pressed(slot: CombatSlot, character: CombatCharacter)


@onready var target_marks: Dictionary = {
	primary = $HealthBar/TargetMarks/Primary,
	secondary = $HealthBar/TargetMarks/Secondary,
}
@onready var selected: bool:
	get:
		return $HealthBar/Selected.visible
	set(value):
		$HealthBar/Selected.visible = value

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
	target_marks.primary.hide()
	target_marks.secondary.hide()
	selected = false


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
		_character.mouse_entered.connect(_on_mouse_entered_character)
		_character.mouse_exited.connect(_on_mouse_exited_character)
		_character.input_event.connect(_on_character_input_event)


func _on_child_exited_tree(child: Node) -> void:
	var c: CombatCharacter = child as CombatCharacter
	if c and _character == c:
		_character = null
		_health_bar.hide()
		_character.mouse_entered.disconnect(_on_mouse_entered_character)
		_character.mouse_exited.disconnect(_on_mouse_exited_character)
		_character.input_event.disconnect(_on_character_input_event)


func _on_mouse_entered_character() -> void:
	mouse_entered.emit(self, _character)


func _on_mouse_exited_character() -> void:
	mouse_exited.emit(self, _character)


func _on_character_input_event(_c: Node, e: InputEvent, _ep: Vector3, _n: Vector3, _si: int) -> void:
	var me: InputEventMouseButton = e as InputEventMouseButton
	if me and me.pressed and (me.button_index == MOUSE_BUTTON_LEFT or me.button_index == MOUSE_BUTTON_MASK_RIGHT):
		mouse_pressed.emit(self, _character)
