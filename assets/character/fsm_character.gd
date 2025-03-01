extends FSM
class_name FSMTestCharacter


const STATES_PATH = "states\\%s.gd"

var _states = {
	idle = preload(STATES_PATH % "idle").new(),
	run = preload(STATES_PATH % "run").new(),
}

var _actions = {
	move = "Move"
}


func _get_initial_state() -> FSMState:
	return _states.idle


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_actions.move, true):
		_set_state(_states.run)
	else:
		_set_state(_states.idle)
	super._input(event)


func _update_current_state(delta: float):
	super._update_current_state(delta)
