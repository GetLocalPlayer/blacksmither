@icon("res://textures/icons/godot_node/node_3D/icon_character.png")
@tool
extends Node3D
class_name CombatCharacter


signal clicked(character: CombatCharacter)
signal hovered(character: CombatCharacter)
signal unhovered(character: CombatCharacter)
signal weapon_equipped(weapon: Weapon)
signal weapon_unequipped(weapon: Weapon)

signal ability_cast
signal retreated


@onready var animation_tree: AnimationTree = $Model/AnimationTree
@onready var _abilities: Array[CombatAbility] = Array($Abilities.get_children(), TYPE_OBJECT, "Node", CombatAbility)
@onready var _ui: Dictionary[String, Control] = {
	buffs = $UI/Buffs,
	debuffs = $UI/Debuffs,
	health_bar = $UI/HealthBar,
}
# Тело персонажа, которое используется для взаимодействия как с курсором
# так и для проверки дистанции до других персонажей. Функция get_radius
# возвращает радиус физического цилиндра (CollisionShape) этого тела.
# Это же тело используется для обозначения габаритов персонажа как aabb.
@onready var _body: Area3D = $Body
# Shape должен быть цилиндром CylinderShape3D
@onready var _body_shape: CollisionShape3D = _body.get_node("CollisionShape3D")
@onready var _fsm: FSMCombatCharacter = $FSM

@onready var _ui_attachments: Dictionary[String, Marker3D] = {
	buffs = $UIAttachments/Buffs,
	debuffs = $UIAttachments/Debuffs,
	health_bar = $UIAttachments/HealthBar,
}

enum UITypes {BUFFS, DEBUFFS, HEALTH_BAR}

@export var portrait: CompressedTexture2D = null
@export var character_name: String = "Character Name"
## Speed - скорость передвижения по карте
@export var speed: float = 2.
## Haste - скорость перемещения в очереди сражения
@export var haste: int = 50

@export var max_health: float = 100:
	get:
		return max_health
	set(value):
		max_health = value if value >= 0. else 0.
		if is_node_ready():
			_ui.health_bar.max_value = max_health

@export var health: float = 100:
	get:
		return health
	set(value):
		health = clamp(value, 0, max_health)
		if is_node_ready():
			_ui.health_bar.value = health

@export var max_mana: float = 100
@export var mana = max_mana

@export var attack_damage: int = 3


## Задает слои союзников. Если текущий и целевой персонажи
## имеют хотя бы один общий слой, текущий может применить
## на целевого способности с положительным эффектом.
@export_flags_2d_physics var ally_layers = 1

# Этой переменной присваивается выбранная в бою
# способность, она и будет применена на цель.
var selected_ability: CombatAbility = null

# Персонаж (CombatCharacter) на которого будет
# пременена выбранная способность (selected_ability)
var target: CombatCharacter
# Место, куда возвращается персонаж после применения
# способности, если тот сошел с места в процессе
# ее применения.
@onready var retreat_position: Vector3 = global_position

## Экипированное оружие.
## Оружие должно быть дочерним нодом персонажа.
## В момент инициализации (_ready) присваивает первое
## не сломанное из дочерних нодов типа Weapon.
## Если текущее значение `null`, будет экипировано
## первое отремонтированное оружие среди дочерних
## нодов типа Weapon.
@export() var equipped_weapon: Weapon:
	get:
		return equipped_weapon
	set(value):
		if value:
			if value.is_broken():	
				push_warning("Can't assing a broken weapon.")
				return
			if not value in get_children():
				push_warning("Weapon must be a direct children to be equipped.")
				return
		if equipped_weapon:
			equipped_weapon.broken.disconnect(_on_equipped_weapon_broken)
			weapon_unequipped.emit(equipped_weapon)
		equipped_weapon = value
		if value:
			weapon_equipped.emit(value)
			value.broken.connect(_on_equipped_weapon_broken)


func get_equipped_weapon() -> Weapon:
	return equipped_weapon

	
func cast_ability() -> void:
	assert(target is CombatCharacter, "Must set `target` to `CombatCharacter` first.")
	_fsm.cast_ability()


func get_abilities() -> Array[CombatAbility]:
	return _abilities


func get_aabb(exclude_top_level_transform: bool = true) -> AABB:
	var top_transform = Transform3D.IDENTITY if exclude_top_level_transform else transform
	var shape = _body_shape.shape
	var half_size = Vector3(shape.radius, shape.height * 0.5, shape.radius)
	return _body_shape.transform * _body.transform * top_transform * AABB(_body.position - half_size, half_size * 2)


func take_damage(value: float) -> void:
	health -= value
	_fsm.take_damage()


func is_alive() -> bool:
	return not is_dead()


func is_injured() -> bool:
	return is_alive() and health/max_health < 0.5


func is_dead() -> bool:
	return health <= 0


func get_children_weapon() -> Array[Weapon]:
	var result: Array[Weapon]
	for child: Node in get_children():
		var weapon: Weapon = child as Weapon
		if weapon:
			result.append(weapon)
	return result

	
func get_ui_position(type: UITypes) -> Vector2:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera: return Vector2.ZERO
	match type:
		UITypes.HEALTH_BAR:
			return camera.unproject_position(_ui_attachments.health_bar.global_position)
		UITypes.BUFFS:
			return camera.unproject_position(_ui_attachments.buffs.global_position)
		UITypes.DEBUFFS:
			return camera.unproject_position(_ui_attachments.debuffs.global_position)
	return Vector2.ZERO


func get_radius() -> float:
	return _body_shape.shape.radius


func _ready() -> void:
	_ui.health_bar.max_value = max_health
	_ui.health_bar.value = health
	_body.mouse_entered.connect(hovered.emit.bind(self))
	_body.mouse_exited.connect(unhovered.emit.bind(self))
	_body.input_event.connect(_on_input_event)
	for child: Node in get_children():
		_on_child_entered_tree(child)
	child_entered_tree.connect(_on_child_entered_tree)
		
		
func _on_input_event(_c: Node, e: InputEvent, _ep: Vector3, _n: Vector3, _si: int) -> void:
	var me: InputEventMouseButton = e as InputEventMouseButton
	if me and me.pressed and me.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)


func _process(_delta: float) -> void:
	if _ui.health_bar.visible:
		_ui.health_bar.position = get_ui_position(UITypes.HEALTH_BAR) - _ui.health_bar.pivot_offset
	if _ui.buffs.visible:
		_ui.buffs.position = get_ui_position(UITypes.BUFFS) - _ui.buffs.pivot_offset
		_ui.debuffs.position = get_ui_position(UITypes.DEBUFFS) - _ui.debuffs.pivot_offset


func _on_child_entered_tree(child: Node) -> void:
	var weapon: Weapon = child as Weapon
	if weapon:
		var on_repaired: Callable = _on_weapon_repaired.bind(weapon)
		weapon.repaired.connect(on_repaired)
		var on_exited: Callable = func() -> void:
			weapon.repaired.disconnect(on_repaired)
			if equipped_weapon == weapon:
				equipped_weapon = null
				for w: Weapon in get_children_weapon():
					if not w.is_broken():
						equipped_weapon = w
						break
		weapon.tree_exited.connect(on_exited, CONNECT_ONE_SHOT)
		if not equipped_weapon and not weapon.is_broken():
			equipped_weapon = weapon


func _on_weapon_repaired(restored: int, weapon: Weapon) -> void:
	if not equipped_weapon and restored == weapon.durability:
		equipped_weapon = weapon


func _on_equipped_weapon_broken() -> void:
	equipped_weapon = null
	for weapon: Weapon in get_children_weapon():
		if weapon and not weapon.is_broken():
			equipped_weapon = weapon
