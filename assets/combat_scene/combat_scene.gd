extends Node3D


var action_queue: Array[CombatSlot] = []

@onready var _player: Node = $Player
@onready var _enemy: Node = $Enemy
@onready var _ability_bar: HBoxContainer = $AbilityBar
# This node is the basic setup to create buttons
# for abilities duplicating it.
@onready var _base_button: TextureButton = $AbilityBar/BaseButton

# Recycling of button abilities not to create new
# ones for each unique ability. Probably an overkill
# optimization but meh.
var _recycled_buttons: Array[TextureButton] = []

func _recycle_button(button: TextureButton) -> void:
	if _recycled_buttons.has(button):
		return
	button.get_parent().remove_child(button)
	_recycled_buttons.append(button)
	button.hide()
	if button.parent:
		button.parent.remove_child(button)
	for signal_dict: Dictionary in button.get_signal_list():
		for connection: Dictionary in button.get_signal_connection_list(signal_dict.name):
			connection.signal.disconnect(connection.callable)

func _get_button() -> TextureButton:
	if not _recycled_buttons.is_empty():
		return _recycled_buttons.pop_back()
	return _base_button.duplicate()
	

# Used to show selection around an ability button
# if the ability is supposed to await for the player
# to choose a target.
@onready var _ability_selection: Panel = $SpellSelection
@onready var _camera: Camera3D = $Camera3D

var _selected_ability: CombatAbility = null


func _ready() -> void:
	# Removing basic button but storing it only
	# to use it as a source of duplicates for
	# new ability buttons.
	_ability_bar.remove_child(_base_button)
	_base_button.hide()
	_ability_selection.hide()
	# Setting action queue for slots
	for slot: CombatSlot in _player.get_children() + _enemy.get_children():
		var character: CombatCharacter = slot.get_character() as CombatCharacter
		if character:
			action_queue.append(slot)
	_run_next_turn()


func _run_next_turn() -> void:
	var slot: CombatSlot = action_queue.pop_front() as CombatSlot
	slot.show_current_character_mark()
	if slot.get_parent() == _player:
		_setup_ability_bar(slot)


func _setup_ability_bar(slot: CombatSlot) -> void:
	var abilities: Array[CombatAbility] = slot.get_character().get_abilities()
	# Making enough buttons for abilities.
	while _ability_bar.get_child_count() < abilities.size():
		_ability_bar.add_child(_get_button())
	while _ability_bar.get_child_count() > abilities.size():
		_recycle_button(_ability_bar.get_child(-1))
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
		btn.pressed.connect(_on_button_pressed.bind(btn, abi))


func _on_button_pressed(button: TextureButton, ability: CombatAbility) -> void:
	match ability.cast_type:
		CombatAbility.CastType.TARGET:
			_ability_selection.reparent(button, false)
			_ability_selection.show()
			_selected_ability = ability
		CombatAbility.CastType.INSTANT:
			pass
		

# Hide SpellSelection node on any click.
# If the click was on a target - the spell
# is used and the SpelLSeleciton isn't needed
# anymore.
# If the click was on an empty space, spell
# selection must be cleared.
# If the click was on the same spell, it
# will just make SpellSeleciton back visible
# right away.
func _input(event: InputEvent) -> void:
	var mouse_click: InputEventMouseButton = event as InputEventMouseButton
	if mouse_click and mouse_click.pressed and (mouse_click.button_index == MOUSE_BUTTON_LEFT or mouse_click.button_index == MOUSE_BUTTON_MASK_RIGHT):
		if _ability_selection.visible:
			_ability_selection.hide()