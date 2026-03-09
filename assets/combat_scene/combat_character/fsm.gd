extends FSM
class_name FSMCombatCharacter


@export var _initial_state: CombatCharacterState


@onready var _states: Dictionary[String, CombatCharacterState] = {
	idle = $Idle,
	approach_target = $ApproachTarget,
	retreat = $Retreat,
	attack = $Attack,
	take_damage = $TakeDamage,
}


func _get_initial_state() -> FSMState:
	return _initial_state


func cast_ability() -> void:
	var caster: CombatCharacter = _get_context()
	if caster.selected_ability.requires_target:
		_clear_queue()
		_set_state(_states.approach_target)
		_queue_states(_states.attack, _states.retreat, _states.idle)
	

func take_damage() -> void:
	_clear_queue()
	_set_state(_states.take_damage)
	_queue_state(_states.idle)