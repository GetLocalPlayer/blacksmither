extends RefCounted
class_name FSMState


signal finished(_context: Node)


func _enter(_context: Node):
    pass


func _handle_input(_context: Node, _event: InputEvent):
    pass


func _update(_context: Node, _delta: float):
    pass


func _exit(_context: Node):
    finished.emit(_context)