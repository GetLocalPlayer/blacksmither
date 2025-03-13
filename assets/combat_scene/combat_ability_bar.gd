extends HBoxContainer
class_name CombatAbilityBar


signal ability_pressed(ability: CombatAbility)


# This node is the basic setup to create buttons
# for abilities duplicating it.
@onready var _base_button: TextureButton = $BaseButton
@onready var _ability_selector: Panel = $BaseButton/AbilitySelector

func _ready() -> void:
	remove_child(_base_button)
	_base_button.hide()
	_base_button.remove_child(_ability_selector)
	_ability_selector.hide()


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
	if _ability_selector.get_parent():
		_ability_selector.get_parent().remove_child(_ability_selector)
		_ability_selector.hide()
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
	if _ability_selector.get_parent():
		_ability_selector.get_parent().remove_child(_ability_selector)
		_ability_selector.hide()
	if ability.cast_type == CombatAbility.CastType.TARGET:
		button.add_child(_ability_selector)
		_ability_selector.show()
	elif _ability_selector.get_parent():
		_ability_selector.get_parent().remove_child(_ability_selector)
		_ability_selector.hide()
	ability_pressed.emit(ability)


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
		if _ability_selector.visible:
			_ability_selector.hide()