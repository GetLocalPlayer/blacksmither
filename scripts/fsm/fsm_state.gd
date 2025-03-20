extends RefCounted
class_name FSMState


signal finished


func _enter(_context: Node) -> void:
	pass


func _handle_input(_context: Node, _event: InputEvent) -> void:
	pass


func _update(_context: Node, _delta: float) -> void:
	pass


func _exit(_context: Node) -> void:
	pass


func _emit_finished() -> void:
	finished.emit()
