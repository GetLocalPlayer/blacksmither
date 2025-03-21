extends Node3D


const BOT_GROUP = "bot"
const PLAYER_GROUP = "player"
const ENEMY_GROUP = "enemies"
@onready var _characters: Array[CombatCharacter] = Array($Characters.get_children(), TYPE_OBJECT, "Node3D", CombatCharacter)
@onready var _ability_bar: CombatAbilityBar = $AbilityBar
@onready var _void_clicker: Area3D = $VoidClicker
var _allowed_targets: Array[CombatCharacter] = []



var _character_queue: Array[CombatCharacter] = []


func _init_for_testing() -> void:
	_character_queue = _characters.duplicate() 


func _ready() -> void:
	_init_for_testing()
	_void_clicker.input_event.connect(_on_void_clicker_input_event)
	# Setting action queue for slots
	
	for c in _characters:
		c.hovered.connect(_on_character_hovered)
		c.unhovered.connect(_on_character_unhovered)
		c.clicked.connect(_on_character_clicked)
	_ability_bar.button_pressed.connect(_on_ability_button_pressed)
	_run_next_turn()


func _run_next_turn() -> void:
	var c: CombatCharacter = _character_queue[0]
	c.selected = true
	if c.is_in_group(PLAYER_GROUP):
		_ability_bar.set_abilities(c.get_abilities())
	if c.is_in_group(BOT_GROUP):
		#start bot actions
		pass


func _on_ability_button_pressed(button: AbilityButton) -> void:
	if not button.button_pressed:
		_character_queue[0].selected_ability = null
		return
	_allowed_targets.clear()
	for c in _characters:
		var filter: int = 0
		if c.is_in_group(ENEMY_GROUP):
			filter |= CombatAbility.AllowedTargets.ENEMY
		else:
			filter |= CombatAbility.AllowedTargets.ALLY
		if c.selected:
			filter |= CombatAbility.AllowedTargets.SELF
		if filter & button.ability.allowed_targets:
			_allowed_targets.append(c)
	_character_queue[0].selected_ability = button.ability


func _on_character_hovered(c: CombatCharacter) -> void:
	c.target_marks.primary.visible = c in _allowed_targets
	

func _on_character_unhovered(c: CombatCharacter) -> void:
	c.target_marks.primary.hide()
	prints("UNhovered:", c)


func _on_character_clicked(character: CombatCharacter) -> void:
	if not _ability_bar.pressed_button:
		return
	#var abi: CombatAbility = _ability_bar.pressed_button.ability
	#abi.apply(_character_queue[0], character)
	prints("Cast spell", _ability_bar.pressed_button.ability, "on", character)
	_character_queue[0].target = character
	_character_queue[0].cast_ability(character)
	_ability_bar.pressed_button.button_pressed = false



func _on_void_clicker_input_event(_c: Node, e: InputEvent, _ep: Vector3, _n: Vector3, _si: int) -> void:
	if not _ability_bar.pressed_button:
		return
	var me: InputEventMouseButton = e as InputEventMouseButton
	if me and me.pressed and (me.button_index == MOUSE_BUTTON_LEFT or me.button_index == MOUSE_BUTTON_MASK_RIGHT):
		_ability_bar.pressed_button.button_pressed = false
		_character_queue[0].selected_ability = null
