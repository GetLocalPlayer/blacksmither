extends FSM
class_name FSMCombatCharacter

const _STATES_PATH = "states/%s.gd"


var _states: Dictionary[String, CombatCharacterState] = {
	idle = preload(_STATES_PATH % "combat_character_state").new("idle"),
	death  = preload(_STATES_PATH % "combat_character_state").new("dead"),
	approach_target  = preload(_STATES_PATH % "approach_target").new("approach_target"),
	cast_ability  = preload(_STATES_PATH % "cast_ability").new("cast_ability"),
	retreat  = preload(_STATES_PATH % "retreat").new("retreat"),
	take_damage  = preload(_STATES_PATH % "take_damage").new("take_damage"),
}


func _get_initial_state() -> FSMState:
	return _states.idle


func take_damage() -> void:
	_set_state(_states.take_damage)


func cast_ability() -> void:
	var caster: CombatCharacter = _get_context()
	if caster.selected_ability.requires_target:
		_clear_queue()
		_queue_states([_states.cast_ability, _states.retreat])
		_set_state(_states.approach_target)
		

func _on_context_ready() -> void:
	super._on_context_ready()
	var character: CombatCharacter = _get_context() as CombatCharacter
	_states.cast_ability.finished.connect(character.ability_cast.emit)
	_states.retreat.finished.connect(character.retreated.emit)

