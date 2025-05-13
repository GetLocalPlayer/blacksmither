@tool
extends Node


@onready var _character: CombatCharacter = owner as CombatCharacter
@onready var _attachments: Dictionary[Weapon.WeaponType, BoneAttachment3D] = {
	Weapon.WeaponType.SWORD: $Sword,
	Weapon.WeaponType.BOW: $Bow,
}
@onready var _remotes: Dictionary[BoneAttachment3D, RemoteTransform3D] = {}


func _ready() -> void:
	for attach: BoneAttachment3D in _attachments.values():
		attach.hide()
		_remotes[attach] = RemoteTransform3D.new()
		attach.add_child(_remotes[attach], false, INTERNAL_MODE_BACK)
	_character.child_order_changed.connect(_on_child_order_changed)
	_character.child_order_changed.emit()


func _on_child_order_changed() -> void:
	print(_attachments)
	for rem: RemoteTransform3D in _remotes.values():
		var weapon: Node = rem.get_node_or_null(rem.remote_path)
		if weapon and weapon.get_script() == Weapon and not _character.get_children().has(weapon):
			rem.remote_path = ""
	var equipped_weapon: Weapon = _character.get_equipped_weapon()
	if equipped_weapon:
		assert(_attachments.has(equipped_weapon.type), "Attachment for \"%s\" weapon type is not implemented yet" % Weapon.WeaponType.find_key(equipped_weapon.type))
		for t: Weapon.WeaponType in _attachments:
			var a: BoneAttachment3D = _attachments[t]
			a.visible = equipped_weapon.type == t
			_remotes[a].remote_path = _remotes[a].get_path_to(equipped_weapon)


			
