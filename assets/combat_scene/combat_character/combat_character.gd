extends Area3D
class_name CombatCharacter


signal clicked(character: CombatCharacter)
signal hovered(character: CombatCharacter)
signal unhovered(character: CombatCharacter)


@onready var _abilities: Array[CombatAbility] = Array($Abilities.get_children(), TYPE_OBJECT, "Node", CombatAbility)
@onready var _playback: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
@onready var _health_bar: ProgressBar = $HealthBar
@onready var _selected_mark: Control = $HealthBar/Selected

@export var _move_speed: float = 2.

@export var max_health: float = 100:
	get:
		return max_health
	set(value):
		max_health = value if value >= 0. else 0.
		if is_node_ready():
			_health_bar.max_value = max_health

@export var health: float = 100:
	get:
		return health
	set(value):
		health = value if value >= 0. else 0.
		if is_node_ready():
			_health_bar.value = health
			_playback.travel(_death_animation)


@onready var target_marks: Dictionary = {
	primary = $HealthBar/TargetMarks/Primary,
	secondary = $HealthBar/TargetMarks/Secondary,
}


var selected: bool = false:
	set(value):
		selected = value
		if is_node_ready():
			_selected_mark.visible = value



@export_group("Animations")
@export var _death_animation: String = "death"
@export var _hit_animation: String = "hit"
@export var _prep_attack_animation: String = "prep_attack"
@export var _attack_impact_animation: String = "attack_impact"


# Must be Vector3 but Vector3 cannot be null.
var to_target = null:
	set(value):
		assert(value == null or value is Vector3, "`to_target` must be a Vector3 or null")
		to_target = value


func get_abilities() -> Array[CombatAbility]:
	return _abilities


func _ready() -> void:
	_health_bar.max_value = max_health
	_health_bar.value = health
	_selected_mark.hide()
	target_marks.primary.hide()
	target_marks.secondary.hide()
	mouse_entered.connect(hovered.emit.bind(self))
	mouse_exited.connect(unhovered.emit.bind(self))
	input_event.connect(_on_input_event)
		
		
func _on_input_event(_c: Node, e: InputEvent, _ep: Vector3, _n: Vector3, _si: int) -> void:
	var me: InputEventMouseButton = e as InputEventMouseButton
	if me and me.pressed and me.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)


func _process(_delta: float) -> void:
	if _health_bar.visible:
		_health_bar.position = get_viewport().get_camera_3d().unproject_position(global_position) - _health_bar.pivot_offset


func _physics_process(delta: float) -> void:
	if to_target:
		global_position = global_position.move_toward(to_target, delta * _move_speed)
		if global_position.is_equal_approx(to_target):
			to_target = null
		
