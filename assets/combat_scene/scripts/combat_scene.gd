extends Node3D

# Название групп которыми управляет игрок либо бот
const _BOT_GROUP = "bot"
const _PLAYER_GROUP = "player"

## Задержка перед началом хода каждого персонажа для красоты.
@export var _start_delay: float = 1


@onready var _queue: CombatQueue = $Queue
@onready var _camera: CombatSceneCamera = $Camera3D
@onready var _player: CombatScenePlayer = $Player


func _ready() -> void:
	_queue.init()
	_camera.set_view_on_characters(_queue.get_characters(), true)
	#for c: CombatCharacter in _queue.get_characters():
	#	c.retreated.connect(_on_character_retreated)
	var tween = create_tween()
	tween.tween_interval(_start_delay)
	tween.tween_callback(_run_next_turn)
	

func _run_next_turn() -> void:
	var current_character = await _queue.update()
	var player_group = _PLAYER_GROUP if current_character.is_in_group(_PLAYER_GROUP) else _BOT_GROUP
	_player.run(_queue.get_characters(), _queue.get_characters().find(current_character), _camera, player_group)
	await current_character.retreated
	var tween = create_tween()
	tween.tween_interval(_start_delay)
	tween.tween_callback(_camera.focus_view_on_characters.bind(_queue.get_characters()))
	await  tween.finished
	_run_next_turn()
