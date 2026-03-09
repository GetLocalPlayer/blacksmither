@tool
extends PanelContainer
class_name CombatQueueEntry

# Персонаж, который закреплен за записью
var character: CombatCharacter
# Текущее положение в очереди
var queue_position := 0
# Количество раз персонаж совершает действие
# (если его скорость в очереди позволяет действовать
# несколько раз за ход)
var turns := 0