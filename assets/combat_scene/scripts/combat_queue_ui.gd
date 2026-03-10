extends CenterContainer
class_name CombatQueueUI

@export var _update_time: float = 1.5
## Сдвиг вниз по вертикали каждого нового портрета
## для предотвращения полного перекрытия.
@export var _entry_vertical_offset: int = 5
@onready var _interval: Control = $Interval
# Базовая нода на основе которой будут создаваться
# остальные.
@onready var _entry_base: TextureRect = $Interval/Entry

var _entries: Dictionary[CombatCharacter, TextureRect] = {}
var _recycled_entries: Array[Control] = []
var _v_offset_accumulated: float = 0

func _ready() -> void:
	_entry_base.get_parent().remove_child(_entry_base)


func _recyle_entry(entry: TextureRect) -> void:
	entry.get_parent().remove_child(entry)
	_recycled_entries.append(entry)


func _get_entry() -> TextureRect:
	return _entry_base.duplicate() if _recycled_entries.is_empty() else _recycled_entries.pop_front()


# pos - значение от 0 до 1, где 0 - крайнее
# левое положение и 1 - крайнее правое.
func _add_entry(character: CombatCharacter, pos: float) -> TextureRect:
	var entry = _get_entry()
	_entries[character] = entry
	entry.texture = character.portrait
	_interval.add_child(entry)
	entry.position = Vector2.ZERO
	entry.position.y = _interval.size.y / 2 + _v_offset_accumulated
	entry.position.x = _interval.size.x * pos
	entry.position -= entry.pivot_offset
	_v_offset_accumulated += _entry_vertical_offset
	return entry


func update(character_position: Dictionary[CombatCharacter, float]) -> void:
	var tween: Tween
	for c in character_position:
		var pos = character_position[c]
		var entry: TextureRect
		if c in _entries:
			entry = _entries[c]
			var final_pos = Vector2(_interval.size.x * pos - entry.pivot_offset.x, entry.position.y)
			tween = entry.create_tween()
			var tween_time = _update_time
			if final_pos.x <= entry.position.x:
				tween_time /= 2
				tween.tween_property(entry, "position",  Vector2(_interval.size.x - entry.pivot_offset.x,  entry.position.y), tween_time)
				tween.tween_property(entry, "position",  Vector2(-entry.pivot_offset.x, entry.position.y), 0)
			tween.tween_property(entry, "position", final_pos, tween_time)
		else:
			entry = _add_entry(c, character_position[c])
	tween = create_tween()
	tween.tween_interval(_update_time)
	await tween.finished
