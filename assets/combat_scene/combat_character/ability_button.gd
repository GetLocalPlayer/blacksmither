extends TextureButton
class_name AbilityButton


var _ability: CombatAbility


@onready var _progress_bar: ProgressBar = $ProgressBar

@onready var _borders: Dictionary = {
	selected = $BorderSelected,
	normal = $BorderNormal
}



func get_ability() -> CombatAbility:
	return _ability


func set_ability(abi: CombatAbility) -> void:
	if is_node_ready():
		if _ability:
			_ability.progress_changed.disconnect(_on_progress_changed)
		if abi:
			_progress_bar.visible = abi.show_progress
			_progress_bar.value = abi.progress
			abi.progress_changed.connect(_on_progress_changed)
	_ability = abi


func _ready() -> void:	
	toggled.connect(_on_toggled)
	_on_toggled(button_pressed)
	_progress_bar.hide()


func _on_toggled(toggled_on: bool) -> void:
	_borders.selected.visible = toggled_on
	_borders.normal.visible = not toggled_on

	
func _on_progress_changed() -> void:
	_progress_bar.value = _ability.progress

