@tool
extends Node


@onready var _character: CombatCharacter = owner as CombatCharacter
@onready var _attachments: Dictionary[Weapon.WeaponType, BoneAttachment3D] = {
	Weapon.WeaponType.SWORD: $Sword,
	Weapon.WeaponType.BOW: $Bow,
}
@onready var _models: Dictionary[BoneAttachment3D, Node3D] = {}


func _ready() -> void:
	for attach in _attachments.values():
		attach.hide()
	_character.weapon_unequipped.connect(_on_weapon_unequipped)
	_character.weapon_equipped.connect(_on_weapon_equipped)
	_character.ready.connect(func() -> void:
		if _character.equipped_weapon:
			_on_weapon_equipped(_character.equipped_weapon)
	, CONNECT_ONE_SHOT)


func _on_weapon_unequipped(weapon: Weapon) -> void:
	if not weapon.type in _attachments:
		push_warning("Attachment for \"%s\" weapon type is not implemented yet" % Weapon.WeaponType.find_key(weapon.type))
		return
	var attach: BoneAttachment3D = _attachments[weapon.type]
	if attach in _models:
		_models[attach].queue_free()
		_models.erase(attach)
		attach.hide()


func _on_weapon_equipped(weapon: Weapon) -> void:
	if not weapon.type in _attachments:
		push_warning("Attachment for \"%s\" weapon type is not implemented yet" % Weapon.WeaponType.find_key(weapon.type))
		return
	var attach: BoneAttachment3D = _attachments[weapon.type]
	if attach in _models:
		_models[attach].queue_free()
	_models[attach] = weapon.model.instantiate() 
	attach.add_child(_models[attach])
	attach.show()
	
