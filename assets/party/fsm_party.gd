extends FSM
class_name FSMParty


signal position_changed(old_position: Vector3, new_position: Vector3)

const STATES_PATH = "states\\%s.gd"

@onready var _states = {
	idle = preload(STATES_PATH % "idle").new(),
	run = preload(STATES_PATH % "run").new(_get_context()),
}

var _actions = {
	move = "Move"
}

@onready var _body = owner


func _get_initial_state() -> FSMState:
	return _states.idle


func _ready() -> void:
	super._ready()
	_states.run.finished.connect(func(_context: Node):
		_set_state(_states.idle)
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_actions.move):
		if _current_state != _states.run:
			_set_state(_states.run)
	super._input(event)


func _update_current_state(delta: float):
	super._update_current_state(delta)
