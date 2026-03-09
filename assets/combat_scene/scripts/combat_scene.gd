extends Node3D

# Название групп которыми управляет игрок либо бот
const BOT_GROUP = "bot"
const PLAYER_GROUP = "player"

## Задержка перед началом для красоты.
@export var _start_delay: float = 1


@onready var _queue: CombatQueue = $Queue
@onready var _camera: CombatSceneCamera = $Camera3D
@onready var _player: CombatScenePlayer = $Player


func _ready() -> void:
	var characters = _get_characters()
	for c: CombatCharacter in _get_characters():
		c.retreated.connect(_on_character_retreated)
	_camera.set_view_on_characters(characters, true)
	var tween = create_tween()
	tween.tween_interval(_start_delay)
	tween.tween_callback(_player.run.bind(characters, 0, _camera))


func _get_characters() -> Array[CombatCharacter]:
	var result: Array[CombatCharacter] = []
	result.append_array(_queue.get_children().filter(func(c: Node) -> bool: return c is CombatCharacter))
	return result


func _on_character_retreated():
	_camera.focus_view_on_characters(_get_characters())