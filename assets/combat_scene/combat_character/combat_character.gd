extends Node3D
class_name Character


signal clicked()
signal mouse_entered()
signal mouse_exited()

@onready var _abilities: Array[CombatAbility] = $Abilities.get_children() as Array[CombatAbility]


@export var max_health: float = 100:
	get:
		return max_health
	set(value):
		health = value if value >= 0. else 0.
		if is_node_ready():
			pass


@export var health: float = 100:
	get:
		return health
	set(value):
		health = value if value >= 0. else 0.
		if is_node_ready():
			pass


@export var clickable: bool = true:
	get:
		return clickable
	set(value):
		clickable = value
		if is_node_ready():
			_clicker.input_ray_pickable = clickable
			

@onready var _clicker: StaticBody3D = $Clicker


func get_abilities() -> Array[CombatAbility]:
	return _abilities


func _ready() -> void:
	_clicker.input_event.connect(_on_click)
	_clicker.mouse_entered.connect(func()-> void: mouse_entered.emit())
	_clicker.mouse_exited.connect(func()-> void: mouse_exited.emit())



func _on_click(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var mouse_click: InputEventMouseButton = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == MOUSE_BUTTON_LEFT and mouse_click.pressed:
		clicked.emit()