extends FSM
class_name FSMCombatCharacter

const _STATES_PATH = "states/%s.gd"


var _states: Dictionary = {
	idle = preload(_STATES_PATH % "combat_character_state").new("idle"),
	death  = preload(_STATES_PATH % "combat_character_state").new("dead"),
	approach_target  = preload(_STATES_PATH % "approach_target").new("approach_target"),
	cast_ability  = preload(_STATES_PATH % "cast_ability").new("cast_ability"),
	retreat  = preload(_STATES_PATH % "retreat").new("retreat"),
	take_damage  = preload(_STATES_PATH % "take_damage").new("take_damage"),
}



var _queue: Array[FSMState] = []:
	set(value):
		_queue = value
		_set_state(_queue.pop_front())


func take_damage() -> void:
	_queue = [_states.take_damage]


func cast_ability() -> void:
	var caster: CombatCharacter = _get_context()
	if caster.selected_ability.requires_target:
		_queue = [_states.approach_target, _states.cast_ability, _states.retreat]


func _get_initial_state() -> FSMState: return _states.idle


func _context_ready() -> void:
	for k in _states:
		var s: CombatCharacterState = _states[k]
		if s.has_signal("finished"):
			s.finished.connect(_on_state_finished)

func _on_state_finished() -> void:
	_set_state(_get_initial_state() if _queue.is_empty() else _queue.pop_front())
