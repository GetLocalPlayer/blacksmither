extends Node3D


var _slot_action_queue: Array[CombatSlot] = []

const ALLY_GROUP = "player_slots"
const ENEMY_GROUP = "enemy_slots"
@onready var _slots: CombatSlotGroup = $Slots
@onready var _ability_bar: CombatAbilityBar = $AbilityBar

func _ready() -> void:
	# Setting action queue for slots
	for slot: CombatSlot in _slots.get_children():
		var character: CombatCharacter = slot.get_character()
		if character:
			_slot_action_queue.append(slot)
			slot.mouse_entered.connect(_on_mouse_entered_slot_character)
			slot.mouse_exited.connect(_on_mouse_exited_slot_character)
			slot.mouse_pressed.connect(_on_slot_character_mouse_pressed)
	_ability_bar.ability_selected.connect(_on_ability_pressed)
	_run_next_turn()


func _run_next_turn() -> void:
	_ability_bar.clear_selection()
	var slot: CombatSlot = _slot_action_queue.pop_front() as CombatSlot
	slot.selected = true
	# Check if the current slot belongs
	# to the player or to the bot
	if _slots.slot_is_player(slot):
		_ability_bar.set_abilities(slot.get_character().get_abilities())
	if _slots.slot_is_bot(slot):
		pass


func _on_ability_pressed() -> void:
	var ability: CombatAbility = _ability_bar.get_selected_ability()
	if ability.cast_type == CombatAbility.CastType.INSTANT:
		for slot: CombatSlot in _slots.get_children():
			slot.mouse_pressed.emit(slot, slot.get_character())


func _on_mouse_entered_slot_character(slot: CombatSlot, _character: CombatCharacter) -> void:
	if not _ability_bar.get_selected_ability():
		return
	var filter: int = 0
	if _slots.are_enemies(_slots.selected_slot, slot):
		filter |= CombatAbility.TargetType.ENEMY
	if _slots.are_allies(_slots.selected_slot, slot):
		filter |= CombatAbility.TargetType.ALLY
	if slot.selected:
		filter |= CombatAbility.TargetType.SELF
	if filter & _ability_bar.get_selected_ability().target_type:
		slot.target_marks.primary.show()
	


func _on_mouse_exited_slot_character(slot: CombatSlot, _character: CombatCharacter) -> void:
	slot.target_marks.primary.hide()


func _on_slot_character_mouse_pressed(slot: CombatSlot, character: CombatCharacter) -> void:
	prints("Cast spell", _ability_bar.get_selected_ability(), "on", character, "in", slot)
