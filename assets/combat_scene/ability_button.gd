extends TextureButton
class_name AbilityButton


var ability: CombatAbility

@onready var _borders: Dictionary = {
	selected = $BorderSelected,
	normal = $BorderNormal
}


func _ready() -> void:
	_borders.selected.visibility_changed.connect(_on_border_visibility_changed)
	_borders.normal.visibility_changed.connect(_on_border_visibility_changed)
	_borders.normal.show()


func _on_border_visibility_changed() -> void:
	_borders.selected.visible = not _borders.normal.visible
	_borders.normal.visible = not _borders.selected.visible
	
