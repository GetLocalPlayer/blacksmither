extends FSM


const _STATES_PATH = "states/%s.gd"

var _states: Dictionary = {
	idle = preload(_STATES_PATH % "idle").new(),
	approach_character = preload(_STATES_PATH % "approach_character").new(),
}


var _queue: Array[FSMState] = []


func _get_initial_state() -> FSMState: return _states.idle


func _ready() -> void:
	super._ready()
	for k in _states:
		var s: FSMState = _states[k]
		if s.has_signal("finished"):
			s.finished.connect(_on_state_finished)


func _on_state_finished() -> void:
	_queue.pop_front()
	if _queue.is_empty():
		_set_state(_get_initial_state())