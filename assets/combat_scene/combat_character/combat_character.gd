@icon("res://textures/icons/godot_node/node_3D/icon_character.png")
@tool
extends Node3D
class_name CombatCharacter


signal clicked(character: CombatCharacter)
signal hovered(character: CombatCharacter)
signal unhovered(character: CombatCharacter)
signal character_detected(character: CombatCharacter)
signal weapon_equipped(weapon: Weapon)
signal weapon_unequipped(weapon: Weapon)

signal ability_cast()
signal retreated()


@onready var model_animation_tree: CombatCharacterAnimationTree = $Model/AnimationTree
@onready var model_playback: AnimationNodeStateMachinePlayback = model_animation_tree.get("parameters/model_playback")

@onready var _abilities: Array[CombatAbility] = Array($Abilities.get_children(), TYPE_OBJECT, "Node", CombatAbility)
@onready var _health_bar: ProgressBar = $HealthBar
@onready var _selected_mark: Control = $HealthBar/Selected
@onready var _buffs_debuffs_attachment: Marker3D = $BuffsDebuffsAttachment
@onready var _buffs: TextureRect = %Buffs
@onready var _debuffs: TextureRect = %Debuffs
@onready var _mouse_detector: Area3D = $MouseDetector
@onready var _character_detector: Area3D = $CharacterDetector
## Is used by camera in combat scene to fit the character in the camera's fov
@onready var _aabb: MeshInstance3D = $AABB
@onready var _fsm: FSMCombatCharacter = $FSM

@export var portrait: CompressedTexture2D = null
@export var character_name: String = "Character Name"
@export var move_speed: float = 2.

@export var max_health: float = 100:
	get:
		return max_health
	set(value):
		max_health = value if value >= 0. else 0.
		if is_node_ready():
			_health_bar.max_value = max_health

@export var health: float = 100:
	get:
		return health
	set(value):
		health = clamp(value, 0, max_health)
		if is_node_ready():
			_health_bar.value = health

@export var max_mana: float = 100
@export var mana = max_mana

@export var attack_damage: int = 3


## Defines ally layers. Characters that have at least
## one layer in common are considered allies and can
## use friendly abilities on each other.
## Characters that are not presented in any ally layer
## are hostile to everyone.
@export_flags_2d_physics var ally_layers = 1

@onready var target_marks: Dictionary = {
	primary = $HealthBar/TargetMarks/Primary,
	secondary = $HealthBar/TargetMarks/Secondary,
}

var selected: bool = false:
	set(value):
		selected = value
		if is_node_ready():
			_selected_mark.visible = value

# What ability is selected, will be cast on use
var selected_ability: CombatAbility = null

# Character's target. Ability will be cast
# on this target. The character will approach
# this target to cast ability in melee.
var target: CombatCharacter
@onready var retreat_position: Vector3 = global_position

# On node ready will be assigned to the first 
# non-broken Weapon-child. When the equipped
# weapon is broken, first non-broken Weapon-
# child is getting equipped.
@export var equipped_weapon: Weapon:
	get:
		return equipped_weapon
	set(value):
		if equipped_weapon:
			equipped_weapon.broken.disconnect(_on_equipped_weapon_broken)
			weapon_unequipped.emit(equipped_weapon)
		equipped_weapon = value
		if value:
			weapon_equipped.emit(value)
			value.broken.connect(_on_equipped_weapon_broken)


func cast_ability() -> void:
	assert(target is CombatCharacter, "Must set `target` to `CombatCharacter` first.")
	_fsm.cast_ability()


func get_abilities() -> Array[CombatAbility]:
	return _abilities


func get_aabb(exclude_transform: bool = true) -> AABB:
	return _aabb.transform * (Transform3D.IDENTITY if exclude_transform else transform) * _aabb.custom_aabb


func take_damage(value: float) -> void:
	health -= value
	_fsm.take_damage()


func is_dead() -> bool:
	return health <= 0.

func is_alive() -> bool:
	return not is_dead()


func get_children_weapon() -> Array[Weapon]:
	var result: Array[Weapon]
	for child: Node in get_children():
		var weapon: Weapon = child as Weapon
		if weapon:
			result.append(weapon)
	return result

	

func _ready() -> void:
	_health_bar.max_value = max_health
	_health_bar.value = health
	_selected_mark.hide()
	target_marks.primary.hide()
	target_marks.secondary.hide()
	_mouse_detector.mouse_entered.connect(hovered.emit.bind(self))
	_mouse_detector.mouse_exited.connect(unhovered.emit.bind(self))
	_mouse_detector.input_event.connect(_on_input_event)
	_character_detector.area_entered.connect(func(area: Area3D) -> void: if area.owner is CombatCharacter: character_detected.emit(area.owner))
	for child: Node in get_children():
		_on_child_entered_tree(child)
	child_entered_tree.connect(_on_child_entered_tree)
		
		
func _on_input_event(_c: Node, e: InputEvent, _ep: Vector3, _n: Vector3, _si: int) -> void:
	var me: InputEventMouseButton = e as InputEventMouseButton
	if me and me.pressed and me.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)


func _process(_delta: float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera:
		if _health_bar.visible:
			_health_bar.position = get_viewport().get_camera_3d().unproject_position(global_position) - _health_bar.pivot_offset
		if _buffs.visible:
			_buffs.position = get_viewport().get_camera_3d().unproject_position(_buffs_debuffs_attachment.global_position) - _buffs.pivot_offset
			_debuffs.position = get_viewport().get_camera_3d().unproject_position(_buffs_debuffs_attachment.global_position) - _debuffs.pivot_offset


func _on_child_entered_tree(child: Node) -> void:
	var weapon: Weapon = child as Weapon
	if weapon:
		var on_repaired: Callable = _on_weapon_repaired.bind(weapon)
		weapon.repaired.connect(on_repaired)
		weapon.tree_exited.connect(func() -> void:
			if equipped_weapon == weapon:
				equipped_weapon = null
				for w: Weapon in get_children_weapon():
					if not w.is_broken():
						equipped_weapon = w
						break
			weapon.repaired.disconnect(on_repaired)
		, CONNECT_ONE_SHOT)
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

