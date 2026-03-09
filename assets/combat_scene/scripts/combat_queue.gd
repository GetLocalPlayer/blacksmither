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

var _character_position: Dictionary[CombatCharacter, float] = {}
	

# Очищает очередь и добавляет в очередь всех
# CombatCharacters которые являются прямыми
# потомками этой ноды в сцене.
func init_from_children() -> void:
	clear()
	for node in get_children():
		if node is CombatCharacter:
			add(node)


# Добавляет персонажа в очередь
func add(...characters: Array) -> void:
	for c in characters:
		assert(c is CombatCharacter, "Combat queue supports only CombatCharacter!")
		_character_position[c] = 0


# Обнуляет положение всех персонажей в очереди
func reset() -> void:
	for c in _character_position:
		_character_position[c] = 0


# Удаляет всех персонажей из очереди
func clear() -> void:
	_character_position.clear()


# Обновляет положение всех персонажей в очереди.
# Возвращает список персонажей в порядке очереди.
# Один персонаж может оказаться в списке несколько
# раз, если его скорость позволяет ему пересечь
# несколько интервалов с текущего положенияза
# один ход.
# Возвращает пустой список, если ни один персонаж
# не пересек ни одной границы за одно обновление.
func update() -> Array[CombatCharacter]:
	var result: Array[CombatCharacter] = []
	for c in _character_position:
		var pos = _character_position[c]
		var relative_pos = fmod(pos, _interval)
		var new_relative_pos = relative_pos + c.haste
		while new_relative_pos > _interval:
			new_relative_pos -= _interval
			result.append(c)
		_character_position[c] += c.haste
	result.sort_custom(func(a, b) -> bool: return _character_position[a] > _character_position[b])
	return result


# Возвращает нормализованное (то есть отмасштабированное
# к интервалу между 0 и 1) положение персонажа в очереди
# между последней и следующей границей интервала.
func get_position_normalized(c: CombatCharacter) -> float:
	assert(c in _character_position, "Given CombatCharacter is not in the queue!")
	return fmod(_character_position[c], _interval)/_interval
		
