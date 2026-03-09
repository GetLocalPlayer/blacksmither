extends Node
class_name CombatScenePlayer


const _BOT_GROUP = "bot"
const _PLAYER_GROUP = "player"

## Коэффициент масштабирования текущего персонажа
@export var _active_character_scale: float = 1.15
## Коэффициент масштабирования персонажа под курсором
## при выборе цели для способности
@export var _hovered_character_scale: float = 1.15
@export var _hovered_scaling_time: float = 0.15
var _last_hovered_base_scale: Vector3


# Элементы интерфейса для игрока.
@onready var _character_info: CombatCharacterInfo = $UI/CharacterInfo
@onready var _ability_bar: CombatAbilityBar = $UI/AbilityBar
# Пустое пространство для обнуления выбора способности.
@onready var _void_clicker: Area3D = $VoidClicker
@onready var _ui_target_marks: Dictionary[String, Control] = {
	primary = $UI/TargetMarks/Primary,
	secondary = $UI/TargetMarks/Secondary,
}
# Текущий персонаж под контролем.
var _controlled_character: CombatCharacter
var _characters: Array[CombatCharacter]
var _camera: CombatSceneCamera


# Даем игроку персонажа под контроль.
func run(characters: Array[CombatCharacter], current: int, camera: CombatSceneCamera) -> void:
	_clear()
	_controlled_character = characters[current]
	_controlled_character.global_scale(Vector3.ONE * _active_character_scale)
	_characters.append_array(characters)
	# Обновляем панель информации под персонажа
	_character_info.set_character(_controlled_character)
	_character_info.show()
	# Обновляем палку способностей под персонажа
	_ability_bar.set_abilities(_controlled_character.get_abilities())
	_ability_bar.button_pressed.connect(_on_ability_button_pressed)
	_ability_bar.show()
	for c: CombatCharacter in characters:
		c.hovered.connect(_on_character_hovered)
		c.unhovered.connect(_on_character_unhovered)
		c.clicked.connect(_on_character_clicked)	
	_camera = camera
	_camera.focus_view_on_characters(_get_player_characters())


# Убираем контроль и скрываем интерфейс
func _clear() -> void:
	_camera = null
	if _controlled_character:
		_controlled_character.global_scale(Vector3.ONE / _active_character_scale)
		if _controlled_character.target and _controlled_character.target != _controlled_character:
			_controlled_character.target.global_scale(Vector3.ONE / _hovered_character_scale)
	_controlled_character = null
	_character_info.hide()
	if _ability_bar.pressed_button: _ability_bar.pressed_button.button_pressed = false
	_ability_bar.hide()
	for c: CombatCharacter in _characters:
		c.hovered.disconnect(_on_character_hovered)
		c.unhovered.disconnect(_on_character_unhovered)
		c.clicked.disconnect(_on_character_clicked)
	_characters.clear()
	_ui_target_marks.primary.hide()


func _ready() -> void:
	_clear()
	_void_clicker.input_event.connect(_on_void_clicked)
	

func _process(_delta: float) -> void:
	if _ui_target_marks.primary.visible and _controlled_character:
		var tar = _controlled_character.target
		if tar:
			_ui_target_marks.primary.global_position = tar.get_ui_position(tar.UITypes.HEALTH_BAR) - _ui_target_marks.primary.pivot_offset


func _get_player_characters() -> Array[CombatCharacter]:
	var result: Array[CombatCharacter] = _characters.filter(func(c: CombatCharacter) -> bool: return c.is_in_group(_PLAYER_GROUP))
	return result
	

func _on_ability_button_pressed(btn: AbilityButton) -> void:
	_controlled_character.selected_ability = btn.get_ability() if btn.button_pressed else null
	var abi = _controlled_character.selected_ability
	var view_focus: Array[CombatCharacter]
	if abi:
		var filter = func(c: CombatCharacter) -> bool:
			return abi.is_target_valid(_controlled_character, c)
		view_focus = _characters.filter(filter)
	else:
		view_focus = _get_player_characters()
	_camera.focus_view_on_characters(view_focus)
	

func _on_void_clicked(_c: Node, event: InputEvent, ..._others) -> void:
	var e = event as InputEventMouseButton
	if not e or not _ability_bar.pressed_button:
		return
	if not e.button_mask & (MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT): 
		return
	_ability_bar.pressed_button.button_pressed = false
	_controlled_character.selected_ability = null
	_camera.focus_view_on_characters(_get_player_characters())

	
func _on_character_hovered(c: CombatCharacter) -> void:
	var abi = _controlled_character.selected_ability
	if abi and abi.is_target_valid(_controlled_character, c):
		_controlled_character.target = c
		if c != _controlled_character:
			c.create_tween().tween_property(c, "scale", Vector3.ONE * _hovered_character_scale, _hovered_scaling_time)
		_ui_target_marks.primary.show()


func _on_character_unhovered(c: CombatCharacter) -> void:
	_ui_target_marks.primary.hide()
	if c != _controlled_character and  c == _controlled_character.target:
		c.create_tween().tween_property(c, "scale", Vector3.ONE, _hovered_scaling_time)
	_controlled_character.target = null


func _on_character_clicked(c: CombatCharacter) -> void:
	var tar: CombatCharacter = _controlled_character.target
	if tar and tar == c:
		_controlled_character.cast_ability()
		_camera.focus_view_on_characters([_controlled_character, c])
		_clear()
