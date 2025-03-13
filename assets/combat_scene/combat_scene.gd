extends Node3D


var _slot_action_queue: Array[CombatSlot] = []

@onready var _player: Node3D = $Player
@onready var _enemy: Node3D = $Enemy
@onready var _player_slots: Array[CombatSlot] = Array(_player.get_children(), TYPE_OBJECT, "Marker3D", CombatSlot)
@onready var _enemy_slots: Array[CombatSlot] = Array(_enemy.get_children(), TYPE_OBJECT, "Marker3D", CombatSlot)
@onready var _ability_bar: CombatAbilityBar = $AbilityBar
var _pressed_ability: CombatAbility = null


func _ready() -> void:
	# Setting action queue for slots
	for slot: CombatSlot in _player_slots + _enemy_slots:
		var character: CombatCharacter = slot.get_character() as CombatCharacter
		if character:
			_slot_action_queue.append(slot)
			slot.mouse_entered.connect(_on_mouse_entered_slot_character)
			slot.mouse_exited.connect(_on_mouse_exited_slot_character)
			slot.mouse_pressed.connect(_on_slot_character_mouse_pressed)
	_ability_bar.ability_pressed.connect(_on_ability_pressed)
	_run_next_turn()


func _run_next_turn() -> void:
	_pressed_ability = null
	var slot: CombatSlot = _slot_action_queue.pop_front() as CombatSlot
	slot.selected = true
	# Check if the current slot belongs
	# to the player or to the bot
	if slot in _player_slots:
		_ability_bar.set_abilities(slot.get_character().get_abilities())
	else:
		# Bot actions
		pass


func _on_ability_pressed(ability: CombatAbility) -> void:
	_pressed_ability = ability
	if ability.cast_type == CombatAbility.CastType.INSTANT:
		for slot in _player_slots + _enemy_slots:
			slot.mouse_pressed.emit(slot, slot.get_character())


func _on_mouse_entered_slot_character(slot: CombatSlot, character: CombatCharacter) -> void:
	if not _pressed_ability:
		return
	var filter: int = 0
	if slot in _enemy_slots:
		filter |= CombatAbility.TargetType.ENEMY
	if slot in _player_slots:
		filter |= CombatAbility.TargetType.ALLY
	if slot.selected:
		filter |= CombatAbility.TargetType.SELF
	if filter:
		slot.target_marks.primary.show()
	


func _on_mouse_exited_slot_character(slot: CombatSlot, character: CombatCharacter) -> void:
	slot.target_marks.primary.hide()


func _on_slot_character_mouse_pressed(slot: CombatSlot, character: CombatCharacter) -> void:
	prints("Cast spell", _pressed_ability, "on", character, "in", slot)
