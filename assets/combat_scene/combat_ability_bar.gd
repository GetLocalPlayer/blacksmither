extends HBoxContainer
class_name CombatAbilityBar


signal ability_selected()


# This node is the basic setup to create buttons
# for abilities duplicating it.
@onready var _base_button: TextureButton = $BaseButton
@onready var _selector: Panel = $BaseButton/AbilitySelector
var _selected_ability: CombatAbility = null:
	get:
		return _selected_ability
	set(value):
		if is_node_ready() and not value and _selector.get_parent():
			_selector.hide()
			_selector.get_parent().remove_child(_selector)
		_selected_ability = value


func clear_selection() -> void:
	_selected_ability = null


func get_selected_ability() -> CombatAbility:
	return _selected_ability


func _ready() -> void:
	remove_child(_base_button)
	_base_button.hide()
	_base_button.remove_child(_selector)
	_selector.hide()


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
	if _selector.get_parent():
		_selector.get_parent().remove_child(_selector)
		_selector.hide()
	for signal_dict: Dictionary in button.get_signal_list():
		for connection: Dictionary in button.get_signal_connection_list(signal_dict.name):
			connection.signal.disconnect(connection.callable)


func _get_button() -> TextureButton:
	if not _recycled_buttons.is_empty():
		return _recycled_buttons.pop_back()
	return _base_button.duplicate()


func set_abilities(abilities: Array[CombatAbility]) -> void:
	# Making enough buttons for abilities.
	while get_child_count() < abilities.size():
		add_child(_get_button())
	while get_child_count() > abilities.size():
		_recycle_button(get_child(-1) as TextureButton)
	# Set a button for each ability.
	for i: int in range(abilities.size()):
		var btn: TextureButton = get_child(i)
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
	if _selector.get_parent():
		_selector.get_parent().remove_child(_selector)
		_selector.hide()
	if ability.cast_type == CombatAbility.CastType.TARGET:
		button.add_child(_selector)
		_selector.show()
	elif _selector.get_parent():
		_selector.get_parent().remove_child(_selector)
		_selector.hide()
	_selected_ability = ability
	ability_selected.emit()


# Hide SpellSelection node on any click.
# If the click was on a target - the spell
# is used and the SpelLSeleciton isn't needed
# anymore.
# If the click was on an empty space, spell
# selection must be cleared.
# If the click was on the same spell, it
# will just make SpellSeleciton back visible
# right away.
# func _input(event: InputEvent) -> void:
# 	var mouse_click: InputEventMouseButton = event as InputEventMouseButton
# 	if mouse_click and mouse_click.pressed and (mouse_click.button_index == MOUSE_BUTTON_LEFT or mouse_click.button_index == MOUSE_BUTTON_MASK_RIGHT):
# 		if _selector.visible:
# 			_selector.hide()
