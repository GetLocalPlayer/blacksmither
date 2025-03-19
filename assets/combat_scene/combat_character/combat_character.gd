extends Area3D
class_name CombatCharacter


signal clicked(character: CombatCharacter)
signal hovered(character: CombatCharacter)
signal unhovered(character: CombatCharacter)

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

@onready var _abilities: Array[CombatAbility] = Array($Abilities.get_children(), TYPE_OBJECT, "Node", CombatAbility)
@onready var _health_bar: ProgressBar = $HealthBar
@onready var _selected_mark: Control = $HealthBar/Selected

@export var move_speed: float = 2.

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
			playback.travel(_death_animation)


@onready var target_marks: Dictionary = {
	primary = $HealthBar/TargetMarks/Primary,
	secondary = $HealthBar/TargetMarks/Secondary,
}
@onready var _fsm: FSMCombatCharacter = $FSM


var selected: bool = false:
	set(value):
		selected = value
		if is_node_ready():
			_selected_mark.visible = value


var selected_ability: CombatAbility = null


@export_group("Animations")
@export var _death_animation: String = "death"


func cast_ability(target: CombatCharacter) -> void:
	if not selected_ability:
		return
	_fsm.cast_ability(target)


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
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera and _health_bar.visible:
		_health_bar.position = get_viewport().get_camera_3d().unproject_position(global_position) - _health_bar.pivot_offset
