extends TextureButton
class_name AbilityButton


var ability: CombatAbility:
	set(value):
		if is_node_ready():
			if ability:
				ability.progress_changed.disconnect(_on_progress_changed)
			if value:
				_progress_bar.visible = value.show_progress
				_progress_bar.value = value.progress
				value.progress_changed.connect(_on_progress_changed)
		ability = value


@onready var _progress_bar: ProgressBar = $ProgressBar

@onready var _borders: Dictionary = {
	selected = $BorderSelected,
	normal = $BorderNormal
}


func _ready() -> void:	
	toggled.connect(_on_toggled)
	_on_toggled(button_pressed)
	_progress_bar.hide()


func _on_toggled(toggled_on: bool) -> void:
	_borders.selected.visible = toggled_on
	_borders.normal.visible = not toggled_on

	
func _on_progress_changed() -> void:
	_progress_bar.value = ability.progress
