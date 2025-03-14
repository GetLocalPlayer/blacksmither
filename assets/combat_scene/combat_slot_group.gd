extends Node3D
class_name CombatSlotGroup

const PLAYER_GROUP = "player_slots"
const BOT_GROUP = "bot_slots"
@onready var slots: Array[CombatSlot] = Array(get_children(), TYPE_OBJECT, "Marker3D", CombatSlot)
@onready var player_slots: Array[CombatSlot] = slots.filter(func(slot: Node): return slot.is_in_group(PLAYER_GROUP))
@onready var enemy_slots: Array[CombatSlot] = slots.filter(func(slot: Node): return slot.is_in_group(BOT_GROUP))

var selected_slot: CombatSlot:
	get:
		if is_node_ready():
			for s in slots:
				if s.selected:
					return s
		return null
	set(value):
		if is_node_ready():
			var s: CombatSlot = selected_slot
			if s and s != value:
				s.selected = false
				value.selected = true


func are_allies(s1: CombatSlot, s2: CombatSlot) -> bool:
	return (s1.is_in_group(PLAYER_GROUP) and s2.is_in_group(PLAYER_GROUP)) or (s1.is_in_group(BOT_GROUP) and s2.is_in_group(BOT_GROUP))


func are_enemies(s1: CombatSlot, s2: CombatSlot) -> bool:
	return not are_allies(s1, s2)


func slot_is_player(slot: CombatSlot) -> bool:
	return slot.is_in_group(PLAYER_GROUP)


func slot_is_bot(slot: CombatSlot) -> bool:
	return slot.is_in_group(BOT_GROUP)
