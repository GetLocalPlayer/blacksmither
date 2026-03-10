extends Node3D
class_name CombatQueue


# Система очереди во время сражения.
# 
# Система помещает всех персонажей на воображаемую
# прямую в точке начала с координатой 0. В системе
# задается интервал через свойство _interval.
# Можно представить, что через каждые _interval
# едениц, на прямой линии задается воображаемый
# чекпойн. В конце хода, к координатам каждого
# персонажа прибавляется значение его скорости Haste.
# Как только первый персонаж пересекает чекпойнт, 
# ему дозволяется совершить действие.
# Система игнорирует факт смерти персонажа и продолжает
# рассчитывать его очередь даже при нулевом ХП.

@export var _interval: float = 100
@onready var _ui: CombatQueueUI = $UI
var _character_position: Dictionary[CombatCharacter, float] = {}
	

# Очищает очередь и добавляет в очередь всех
# CombatCharacters которые являются прямыми
# потомками этой ноды в сцене.
func init() -> void:
	clear()
	for c: CombatCharacter in get_characters():
		_character_position[c] = 0
	_ui.update(_character_position)
		

# Обнуляет положение всех персонажей в очереди
func reset() -> void:
	for c in get_characters():
		_character_position[c] = 0


# Удаляет всех персонажей из очереди
func clear() -> void:
	_character_position.clear()


# Передвигает в очереди вперед, возвращая первого
# достигшего интервала.
func update() -> CombatCharacter:
	var chars = get_characters()
	# Сортировкщик в порядке первого достигшего интервала
	# исходя из скорости реакции.
	var sorter = func(a: CombatCharacter, b: CombatCharacter) -> bool:
		var dist_a = _interval - _character_position[a]
		var dist_b = _interval - _character_position[b]
		return dist_a / a.haste < dist_b / b.haste
	chars.sort_custom(sorter)
	var factor = (_interval - _character_position[chars[0]]) / chars[0].haste
	var normalized: Dictionary[CombatCharacter, float] = {} # для интерфейса
	for c: CombatCharacter in chars:
		_character_position[c] += c.haste * factor
		normalized[c] = get_position_normalized(c)
	_character_position[chars[0]] = 0
	await _ui.update(normalized)
	return chars[0]
	


# Возвращает нормализованное (то есть отмасштабированное
# к интервалу между 0 и 1) положение персонажа в очереди
# между последней и следующей границей интервала.
func get_position_normalized(c: CombatCharacter) -> float:
	assert(c in _character_position, "Given CombatCharacter is not in the queue!")
	return _character_position[c] / _interval


func get_characters() -> Array[CombatCharacter]:
	var result: Array[CombatCharacter] = []
	result.append_array(get_children().filter(func(c: Node) -> bool: return c is CombatCharacter))
	return result
		
