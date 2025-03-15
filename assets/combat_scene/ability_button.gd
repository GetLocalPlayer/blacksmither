extends TextureButton
class_name AbilityButton


var ability: CombatAbility

@onready var _borders: Dictionary = {
	selected = $BorderSelected,
	normal = $BorderNormal
}


func _ready() -> void:	
	toggled.connect(_on_toggled)
	_on_toggled(button_pressed)


func _on_toggled(toggled_on: bool) -> void:
	_borders.selected.visible = toggled_on
	_borders.normal.visible = not toggled_on

	
