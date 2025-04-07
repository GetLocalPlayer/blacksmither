extends GridContainer
class_name CombatCharacterInfo


var character: CombatCharacter:
	set(value):
		character = value
		if is_node_ready():
			if value != null:
				show()
				_image.texture = value.portrait
				_name.text = value.character_name
				_update_bars()
			else:
				hide()



@onready var _image: TextureRect = $Portrait/Image
@onready var _name: Label = $Portrait/Name
@onready var _health_bar: ProgressBar = $Bars/Health
@onready var _health_bar_label: Label = $Bars/Health/Value
@onready var _mana_bar: ProgressBar = $Bars/Mana
@onready var _mana_bar_label: Label = $Bars/Mana/Value



func _process(_delta: float) -> void:
	if character:
		_update_bars()


func _update_bars() -> void:
	_health_bar.max_value = character.max_health
	_health_bar.value = character.health
	_health_bar_label.text = str(int(character.health))
	_mana_bar.max_value = character.max_mana
	_mana_bar.value = character.mana
	_mana_bar_label.text = str(int(character.mana))
