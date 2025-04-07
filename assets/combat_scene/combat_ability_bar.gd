extends NinePatchRect
class_name CombatAbilityBar


signal button_pressed(button: AbilityButton)

@onready var _buttons_container: HBoxContainer = $ButtonsContainer
@onready var _base_button: TextureButton = $ButtonsContainer/BaseButton
@onready var _separator: VSeparator = $ButtonsContainer/VSeparator
@onready var _button_group: ButtonGroup = _base_button.button_group


var pressed_button: AbilityButton: 
	get:
		return _button_group.get_pressed_button() as AbilityButton


func _ready() -> void:
	_buttons_container.remove_child(_base_button)
	_buttons_container.remove_child(_separator)
	_buttons_container.add_child(_separator, false, INTERNAL_MODE_FRONT)
	_base_button.hide()
	_button_group.pressed.connect(button_pressed.emit)


# Recycling of button abilities not to create new
# ones for each unique ability. Probably an overkill
# optimization but meh.
var _recycled_buttons: Array[AbilityButton] = []

func _recycle_button(button: AbilityButton) -> void:
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


func _get_button() -> AbilityButton:
	return _base_button.duplicate() if _recycled_buttons.is_empty() else _recycled_buttons.pop_back()


func set_abilities(abilities: Array[CombatAbility]) -> void:
	# Making enough buttons for abilities.
	while _buttons_container.get_child_count() < abilities.size():
		_buttons_container.add_child(_get_button())
	while _buttons_container.get_child_count() > abilities.size():
		_recycle_button(_buttons_container.get_child(-1) as AbilityButton)
	if pressed_button:
		pressed_button.button_pressed = false
	# Set a button for each ability.
	for i: int in range(abilities.size()):
		var btn: AbilityButton = _buttons_container.get_child(i)
		var abi: CombatAbility = abilities[i]
		btn.ability = abi
		btn.toggle_mode = true
		btn.texture_disabled = abi.icon
		btn.texture_focused = abi.icon
		btn.texture_hover = abi.icon
		btn.texture_normal = abi.icon
		btn.texture_pressed = abi.icon
		btn.show()
