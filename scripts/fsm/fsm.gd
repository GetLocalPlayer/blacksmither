extends Node
class_name FSM


var _current_state: FSMState


func _get_context() -> Node:
	return get_parent()


func _get_initial_state() -> FSMState:
	return null


func _set_state(new_state: FSMState):
	if _current_state != null:
		_current_state._exit(_get_context())
	_current_state = new_state
	if new_state != null:
		new_state._enter(_get_context())


func _update_current_state(delta: float):
	_current_state._update(_get_context(), delta)


func _ready() -> void:
	_get_context().ready.connect(_context_ready, CONNECT_ONE_SHOT)


func _context_ready() -> void:
	_set_state(_get_initial_state())


func _input(event) -> void:
	if _current_state != null:
		_current_state._handle_input(_get_context(), event)


func _physics_process(delta) -> void:
	if _current_state != null:
		_update_current_state(delta)
