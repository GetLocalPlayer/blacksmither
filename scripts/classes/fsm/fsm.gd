extends Node
class_name FSM


# Finite State Machine
# Allows to set current state and to queue states.
# When the current state is finished it automatically
# calls its "_exit" method. 
# FSM invokes "_update" method of the current state
# each physical frame.
# FSM passes input event into the current state.

var _queue: Array[FSMState] = []
var _current_state: FSMState


func _clear_queue() -> void:
	_queue.clear()


func _get_context() -> Node:
	return get_parent()


# Must be overriden in descendant classes
func _get_initial_state() -> FSMState:
	return null


func _set_state(new_state: FSMState) -> void:
	if _current_state:
		_current_state._exit(_get_context())
		_current_state.finished.disconnect(_on_state_finished)
	_current_state = new_state
	if new_state:
		new_state.finished.connect(_on_state_finished)
		new_state._enter(_get_context())


func _queue_state(new_state: FSMState) -> void:
	assert(new_state != null, "Can't queue `null` as a state")
	if not _current_state:
		_set_state(_get_initial_state() if _queue.is_empty() else _queue.pop_front())
	else:
		_queue.append(new_state)


func _queue_states(states: Array[FSMState]) -> void:
	for s: FSMState in states:
		_queue_state(s)


func _on_state_finished() -> void:
	if _queue.is_empty():
		_set_state(_get_initial_state())
	else:
		_set_state(_queue.pop_front())


func _update_current_state(delta: float) -> void:
	_current_state._update(_get_context(), delta)


func _ready() -> void:
	_get_context().ready.connect(_on_context_ready, CONNECT_ONE_SHOT)


func _on_context_ready() -> void:
	_set_state(_get_initial_state())


func _input(event) -> void:
	if _current_state:
		_current_state._handle_input(_get_context(), event)


func _physics_process(delta) -> void:
	if _current_state:
		_update_current_state(delta)
