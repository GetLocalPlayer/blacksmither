extends Node3D


var action_queue: Array[Marker3D] = []

@onready var _player: Node = $Player
@onready var _enemy: Node = $Enemy


func _ready() -> void:
	for slot in _player.get_children():
		if slot.get_child_count() > 0:
			action_queue.append(slot)
	
	for slot in _enemy.get_children():
		if slot.get_child_count() > 0:
			action_queue.append(slot)