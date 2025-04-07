extends Node3D


@export var _active_character_scale: float = 1.1
@export var _hovered_character_scale: float = 1.1

const BOT_GROUP = "bot"
const PLAYER_GROUP = "player"
@onready var _characters: Array[CombatCharacter] = Array($Characters.get_children(), TYPE_OBJECT, "Node3D", CombatCharacter)
@onready var _player_characters: Array[CombatCharacter] = _characters.filter(func(c: CombatCharacter) -> bool: return c.is_in_group(PLAYER_GROUP))
@onready var _bot_characters: Array[CombatCharacter] = _characters.filter(func(c: CombatCharacter) -> bool: return c.is_in_group(BOT_GROUP))
@onready var _ability_bar: CombatAbilityBar = $AbilityBar
# A node to catch clicks on void which means
# clear selected ability on ability bar.
@onready var _void_clicker: Area3D = $VoidClicker
@onready var _camera: Camera3D = $Camera3D


# The targets that are allowed to be 
# hovered and clicked on on ability
# targeting.
var _allowed_targets: Array[CombatCharacter] = []
# The queue of characters to act
var _character_queue: Array[CombatCharacter] = []


func _init_for_testing() -> void:
	_character_queue = _characters.duplicate() 


func _ready() -> void:
	_init_for_testing()
	_void_clicker.input_event.connect(_on_void_clicker_input_event)

	for c in _characters:
		c.hovered.connect(_on_character_hovered)
		c.unhovered.connect(_on_character_unhovered)
		c.clicked.connect(_on_character_clicked)
	_ability_bar.button_pressed.connect(_on_ability_button_pressed)
	for c in _characters:
		c.ability_cast.connect(_on_ability_cast)
		c.retreated.connect(_on_character_retreated)
	_run_next_turn()



# Choose next character to act in the queue
func _run_next_turn() -> void:
	var c: CombatCharacter = _character_queue[0]
	c.selected = true
	c.global_scale(Vector3.ONE * _active_character_scale)
	_camera.set_view_on_characters(_player_characters if c.is_in_group(PLAYER_GROUP) else _bot_characters)
	#_camera.accent_on = c
	if c.is_in_group(PLAYER_GROUP):
		_ability_bar.set_abilities(c.get_abilities())
	if c.is_in_group(BOT_GROUP):
		#start bot actions
		pass


# When an ability is pressed, fills _allowed_targets
# array with characters that can be victims of that
# ability.
func _on_ability_button_pressed(button: AbilityButton) -> void:
	var caster: CombatCharacter = _character_queue[0]
	if not button.button_pressed:
		caster.selected_ability = null
		_camera.set_view_on_characters(_player_characters if caster.is_in_group(PLAYER_GROUP) else _bot_characters)
		return
	
	var ability: CombatAbility = button.ability
	_allowed_targets.clear()
	_allowed_targets = _characters.filter(func(target: CombatCharacter) -> bool: return ability.is_target_valid(caster, target))
	#_camera.accent_on = null
	_camera.set_view_on_characters(_allowed_targets)
	caster.selected_ability = button.ability


func _on_character_hovered(c: CombatCharacter) -> void:
	if not c in _allowed_targets:
		return
	c.target_marks.primary.show()
	c.global_scale(Vector3.ONE * _hovered_character_scale)
	#_camera.accent_on = c
	

func _on_character_unhovered(c: CombatCharacter) -> void:
	c.target_marks.primary.hide()
	if c in _allowed_targets:
		c.global_scale(Vector3.ONE / _hovered_character_scale)
	prints("UNhovered:", c)


func _on_character_clicked(character: CombatCharacter) -> void:
	if not _ability_bar.pressed_button:
		return
	if not character in _allowed_targets:
		return
	_allowed_targets.clear()
	prints("Cast spell", _ability_bar.pressed_button.ability, "on", character)
	_ability_bar.pressed_button.button_pressed = false
	_ability_bar.hide()
	var caster: CombatCharacter = _character_queue[0]
	caster.target = character
	#_camera.accent_on = null
	_camera.focus_view_on_characters([caster, caster.target] as Array[CombatCharacter])
	caster.global_scale(Vector3.ONE / _active_character_scale)
	caster.target.global_scale(Vector3.ONE / _hovered_character_scale)
	caster.cast_ability()



# Clearing selection from ability bar if empty space is clicked.
func _on_void_clicker_input_event(_c: Node, e: InputEvent, _ep: Vector3, _n: Vector3, _si: int) -> void:
	if not _ability_bar.pressed_button:
		return
	var me: InputEventMouseButton = e as InputEventMouseButton
	if me and me.pressed and (me.button_index == MOUSE_BUTTON_LEFT or me.button_index == MOUSE_BUTTON_RIGHT):
		_ability_bar.pressed_button.button_pressed = false
		_character_queue[0].selected_ability = null
		_camera.set_view_on_characters(_player_characters if _character_queue[0].is_in_group(PLAYER_GROUP) else _bot_characters)
		#_camera.accent_on = _character_queue[0]




# When character used ability and finished
# cast_ability state
func _on_ability_cast() -> void:
	pass


# When character returned to its retreat
# position
func _on_character_retreated() -> void:
	_ability_bar.show()
	var caster: CombatCharacter = _character_queue.pop_front()
	_character_queue.append(caster)
	caster.selected_ability = null
	caster.target = null
	caster.selected = false
	_camera.clear_focus()
	_run_next_turn()
