extends Node3D


var action_queue: Array[CombatSlot] = []

@onready var _player: Node = $Player
@onready var _enemy: Node = $Enemy
@onready var _ability_bar: HBoxContainer = $AbilityBar
@onready var _base_ability_button: TextureButton= $AbilityBar/BaseButton
@onready var _ability_selection: Panel = $SpellSelection
@onready var _raycast: RayCast3D = $RayCast3D
@onready var _camera: Camera3D = $Camera3D

@export var _raycast_length: float = 100.

var _button_callables: Dictionary = {}
var _selected_ability: CombatAbility = null


func _ready() -> void:
	_ability_bar.remove_child(_base_ability_button)
	_base_ability_button.hide()
	_ability_selection.hide()
	for slot in _player.get_children():
		if slot.get_child_count() > 0:
			action_queue.append(slot)

	
	for slot in _enemy.get_children():
		if slot.get_child_count() > 0:
			action_queue.append(slot)
	_run_next_turn()


func _run_next_turn() -> void:
	var slot: CombatSlot = action_queue.pop_front() as CombatSlot
	slot.show_current_character_mark()
	if slot.get_parent() == _player:
		_set_ability_bar(slot)


func _set_ability_bar(slot: CombatSlot) -> void:
	var abilities: Array[CombatAbility] = slot.get_character_abilities()
	# Clear button signals from previous player turn
	for btn in _button_callables:
		btn.pressed.disconnect(_button_callables[btn])
	_button_callables.clear()
	# Creatign new buttons if there's not enough 
	# for all abilities of the current character.
	while _ability_bar.get_child_count() < abilities.size():
		var btn: TextureButton = _base_ability_button.duplicate()
		_ability_bar.add_child(btn)
		btn.hide()
	# Set a button for each ability.
	for i: int in range(abilities.size()):
		var btn: TextureButton = _ability_bar.get_child(i)
		var abi: CombatAbility = abilities[i]
		btn.toggle_mode = false
		btn.texture_disabled = abi.icon
		btn.texture_focused = abi.icon
		btn.texture_hover = abi.icon
		btn.texture_normal = abi.icon
		btn.texture_pressed = abi.icon
		btn.show()
		_button_callables[btn] = _on_ability_button_pressed.bind(btn, abi)
		btn.pressed.connect(_button_callables[btn])
	# Hide unused buttons if there are more buttons
	# than required left from previous player turn
	for i: int in range(abilities.size(), _ability_bar.get_child_count()):
		_ability_bar.get_child(i).hide()


func _on_ability_button_pressed(button: TextureButton, ability: CombatAbility) -> void:
	match ability:
		CombatAbility.CastType.TARGET:
			_ability_selection.reparent(button, false)
			_ability_selection.show()
			_selected_ability = ability
		CombatAbility.CastType.INSTANT:
			pass
		


# Hide SpellSelection node on any click.
func _input(event: InputEvent) -> void:
	var mouse_click: InputEventMouseButton = event as InputEventMouseButton
	if mouse_click and mouse_click.pressed and (mouse_click.button_index == MOUSE_BUTTON_LEFT or mouse_click.button_index == MOUSE_BUTTON_MASK_RIGHT):
		if _ability_selection.visible:
			_ability_selection.hide()


func _physics_process(_delta: float) -> void:
	if _ability_selection.visible:
		_check_ray_targets(_selected_ability)


func _check_ray_targets(ability: CombatAbility) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	_raycast.global_position = _camera.project_ray_origin(mouse_pos)
	_raycast.target_position = _camera.project_ray_normal(mouse_pos) * _raycast_length
	_raycast.force_raycast_update()
	var collider: Node = _raycast.get_collider() as Node
	var character: Character = collider.owner as Character if collider else null
	if not character:
		return