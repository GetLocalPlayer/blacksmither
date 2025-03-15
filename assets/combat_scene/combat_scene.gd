extends Node3D


const BOT_GROUP = "bot"
const PLAYER_GROUP = "player"
const ENEMY_GROUP = "enemies"
@onready var _characters: Array[CombatCharacter] = Array($Characters.get_children(), TYPE_OBJECT, "Area3D", CombatCharacter)
@onready var _ability_bar: CombatAbilityBar = $UIBase/AbilityBar
@onready var _health_bar_base: ProgressBar = $UIBase/UIBase/HealthBar
@onready var _clicker: Area3D = $Clicker


var _character_queue: Array[CombatCharacter] = []


func _init_for_testing() -> void:
	_character_queue = _characters.duplicate() 


func _ready() -> void:
	_init_for_testing()
	_clicker.input_event.connect(_on_clicker_input_event)
	# Setting action queue for slots
	
	for c in _characters:
		c.mouse_entered.connect(_on_mouse_entered_slot_character)
		c.mouse_exited.connect(_on_mouse_exited_slot_character)
		c.mouse_pressed.connect(_on_slot_character_mouse_pressed)
	_ability_bar.ability_selected.connect(_on_ability_pressed)
	_run_next_turn()


func _run_next_turn() -> void:
	_ability_bar.clear_selection()
	var c: CombatCharacter = _character_queue.pop_front()
	if c.is_in_group(PLAYER_GROUP):
		_ability_bar.set_abilities(c.get_abilities())
	if c.is_in_group(BOT_GROUP):
		#start bot actions
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
	if not slot.target_marks.primary.visible:
		return
	prints("Cast spell", _ability_bar.get_selected_ability(), "on", character, "in", slot)
	_ability_bar.clear_selection()
	slot.target_marks.primary.hide()


func _on_clicker_input_event(_c: Node, e: InputEvent, _ep: Vector3, _n: Vector3, _si: int) -> void:
	var me: InputEventMouseButton = e as InputEventMouseButton
	if me and me.pressed and (me.button_index == MOUSE_BUTTON_LEFT or me.button_index == MOUSE_BUTTON_MASK_RIGHT):
		_ability_bar.clear_selection()
