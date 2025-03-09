extends Node3D
class_name Character


@onready var _clicker: StaticBody3D = $Clicker
@onready var _target: Panel = $HealthBar/Target


func _ready() -> void:
    _clicker.input_event.connect(_on_click)
    _target.hide()


func _on_click(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
    pass


func _on_mouse_entered() -> void:
    _target.show()


func _on_mouse_exited() -> void:
    _target.hide()
