extends Node3D
class_name CombatCharacter


signal clicked(character: CombatCharacter)
signal hovered(character: CombatCharacter)
signal unhovered(character: CombatCharacter)
signal character_detected(character: CombatCharacter)

signal ability_cast()
signal retreated()


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

@onready var _abilities: Array[CombatAbility] = Array($Abilities.get_children(), TYPE_OBJECT, "Node", CombatAbility)
@onready var _health_bar: ProgressBar = $HealthBar
@onready var _selected_mark: Control = $HealthBar/Selected
@onready var _mouse_detector: Area3D = $MouseDetector
@onready var _character_detector: Area3D = $CharacterDetector

@export var portrait: CompressedTexture2D = null
@export var character_name: String = "Character Name"
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

@export var max_mana: float = 100
@export var mana = max_mana

@export var attack_damage: int = 3
## Defines ally layers. Characters on the same
## layers are considered allies and can use friendly
## abilities on each other.
## If a character has all ally layers enabled it will
## be considered an ally to everyone except the characters
## not included in any ally layer.
## Characters that are not presented in any ally layer
## are hostile to everyone.
@export_flags_2d_physics var ally_layers = 1

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

# What ability is selected, will be cast on use
var selected_ability: CombatAbility = null
# What the character targeted on, vector or another character
var target: CombatCharacter
@onready var retreat_position: Vector3 = global_position


func cast_ability() -> void:
	assert(target is CombatCharacter, "Must set `target` to `CombatCharacter` first.")
	_fsm.cast_ability()


func get_abilities() -> Array[CombatAbility]:
	return _abilities


func take_damage(value: float) -> void:
	health -= value
	_fsm.take_damage()


func is_dead() -> bool:
	return health <= 0.

func is_alive() -> bool:
	return not is_dead()


func _ready() -> void:
	_health_bar.max_value = max_health
	_health_bar.value = health
	_selected_mark.hide()
	target_marks.primary.hide()
	target_marks.secondary.hide()
	_mouse_detector.mouse_entered.connect(hovered.emit.bind(self))
	_mouse_detector.mouse_exited.connect(unhovered.emit.bind(self))
	_mouse_detector.input_event.connect(_on_input_event)
	_character_detector.area_entered.connect(func(area: Area3D) -> void: if area.owner is CombatCharacter: character_detected.emit(area.owner))
		
		
func _on_input_event(_c: Node, e: InputEvent, _ep: Vector3, _n: Vector3, _si: int) -> void:
	var me: InputEventMouseButton = e as InputEventMouseButton
	if me and me.pressed and me.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)


func _process(_delta: float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera and _health_bar.visible:
		_health_bar.position = get_viewport().get_camera_3d().unproject_position(global_position) - _health_bar.pivot_offset
