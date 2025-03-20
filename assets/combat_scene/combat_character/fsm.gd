extends FSM
class_name FSMCombatCharacter

const _STATES_PATH = "states/%s.gd"


var _states: Dictionary = {
	idle = preload(_STATES_PATH % "idle"),
	approach_character = preload(_STATES_PATH % "approach_character"),
	cast_ability = preload(_STATES_PATH % "cast_ability"),
	retreat_to = preload(_STATES_PATH % "retreat_to"),
	take_damage = preload(_STATES_PATH % "take_damage"),
}


var _queue: Array[FSMState] = []:
	set(value):
		_queue = value
		for s in _queue:
			if s.has_signal("finished"):
				s.finished.connect(_on_state_finished)
		_set_state(_queue.pop_front())


func take_damage() -> void:
	_queue = [_states.take_damage.new()]


func cast_ability(target: CombatCharacter) -> void:
	var caster: CombatCharacter = _get_context()
	if caster.selected_ability.requires_target:
		_queue = [_states.approach_character.new(target), _states.cast_ability.new(target), _states.retreat_to.new(caster.global_position)]


func _get_initial_state() -> FSMState: return _states.idle.new()


func _on_state_finished() -> void:
	_set_state(_get_initial_state() if _queue.is_empty() else _queue.pop_front())