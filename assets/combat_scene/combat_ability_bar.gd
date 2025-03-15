extends HBoxContainer
class_name CombatAbilityBar


# for abilities duplicating it.
@onready var _base_button: TextureButton = $BaseButton
@onready var button_group = _base_button.button_group


func _ready() -> void:
	remove_child(_base_button)
	_base_button.hide()

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