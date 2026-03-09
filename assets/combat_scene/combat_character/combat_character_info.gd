extends GridContainer
class_name CombatCharacterInfo


@onready var _image: TextureRect = $Portrait/Image
@onready var _name: Label = $Portrait/Name
@onready var _health_bar: ProgressBar = $Bars/Health
@onready var _health_bar_label: Label = $Bars/Health/Value
@onready var _mana_bar: ProgressBar = $Bars/Mana
@onready var _mana_bar_label: Label = $Bars/Mana/Value

var _character: CombatCharacter


func set_character(c: CombatCharacter) -> void:
	_character = c
	if not is_node_ready(): return
	if c != null:
		show()
		_image.texture = c.portrait
		_name.text = c.character_name
		_update_bars()
	else:
		hide()

func _process(_delta: float) -> void:
	if _character:
		_update_bars()


func _update_bars() -> void:
	_health_bar.max_value = _character.max_health
	_health_bar.value = _character.health
	_health_bar_label.text = str(int(_character.health))
	_mana_bar.max_value = _character.max_mana
	_mana_bar.value = _character.mana
	_mana_bar_label.text = str(int(_character.mana))
