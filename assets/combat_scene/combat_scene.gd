extends Node3D


var action_queue: Array[Marker3D] = []

@onready var _player: Node = $Player
@onready var _enemy: Node = $Enemy
@onready var _ability_bar: HBoxContainer = $AbilityBar


func _ready() -> void:
	for slot in _player.get_children():
		if slot.get_child_count() > 0:
			action_queue.append(slot)
			for a in slot.get_character_abilities():
				a.reparent(_ability_bar)
				a.hide()
	
	for slot in _enemy.get_children():
		if slot.get_child_count() > 0:
			action_queue.append(slot)
	_run_next_turn()



func _run_next_turn() -> void:
	var slot = action_queue.pop_front()
	if slot.get_parent() == _player:
		_set_ability_bar(slot)


func _set_ability_bar(slot: CombatSlot) -> void:
	for a in slot.get_character().get_abilities():
		a.show()