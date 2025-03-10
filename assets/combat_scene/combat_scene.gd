extends Node3D


var action_queue: Array[Marker3D] = []

@onready var _player: Node = $Player
@onready var _enemy: Node = $Enemy
@onready var _ability_bar: HBoxContainer = $AbilityBar
@onready var _base_ability_button: TextureButton= $AbilityBar/BaseButton


func _ready() -> void:
	_ability_bar.remove_child(_base_ability_button)
	_base_ability_button.hide()
	for slot in _player.get_children():
		if slot.get_child_count() > 0:
			action_queue.append(slot)
			var abilities: Array[CombatAbility] = slot.get_character_abilities()
			while abilities.size() > _ability_bar.get_child_count():
				var btn: TextureButton = _base_ability_button.duplicate()
				_ability_bar.add_child(btn)
				btn.hide()

	
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
	for i: int in range(abilities.size()):
		var btn: TextureButton = _ability_bar.get_child(i)
		var abi: CombatAbility = abilities[i]
		btn.toggle_mode = abi.toggle_mode
		btn.texture_click_mask = abi.texture_click_mask
		btn.texture_disabled = abi.texture_disabled
		btn.texture_focused = abi.texture_focused
		btn.texture_hover = abi.texture_hover
		btn.texture_normal = abi.texture_normal
		btn.texture_pressed = abi.texture_pressed
		btn.show()
		if btn.toggle_mode:
			btn.toggled.connect(_on_ability_button_toggled.bind(abi))
	for i: int in range(abilities.size(), _ability_bar.get_child_count()):
		_ability_bar.get_child(i).hide()


func _on_ability_button_toggled(toggled: bool, ability: CombatAbility) -> void:
	if not toggled:
		return
	var targets: int = ability.target_type


func _input(event: InputEvent) -> void:
	var mouse_click: InputEventMouseButton = event as InputEventMouseButton
	if mouse_click and mouse_click.pressed and (mouse_click.button_index == MOUSE_BUTTON_LEFT or mouse_click.button_index == MOUSE_BUTTON_MASK_RIGHT):
		print("click")