@tool
extends TextureButton
class_name Ability


@export var title: String = "Empty Name"
@export var description: String = "Empty Description"


enum CastType {TARGET, INSTANT}
enum EffectType {DAMAGE, HEAL}

@export var cast_type: CastType = CastType.TARGET
@export var effect_type: EffectType = EffectType.DAMAGE:
	get:
		return effect_type
	set(value):
		effect_type = value
		if Engine.is_editor_hint():
			notify_property_list_changed()


@export var damage: float = 100:
	get:
		return damage
	set(value):
		damage = value if value >= 0. else 0.


@export var heal: float = 100:
	get:
		return heal
	set(value):
		heal = value if value >= 0. else 0.


func _validate_property(property: Dictionary) -> void:
	var validate_effect_type = func(et: EffectType) -> int:
		return PROPERTY_USAGE_STORAGE | (PROPERTY_USAGE_EDITOR if effect_type == et else PROPERTY_USAGE_NO_EDITOR)

	if property.name == "damage":
		property.usage = validate_effect_type.call(EffectType.DAMAGE)
	if property.name == "heal":
		property.usage = validate_effect_type.call(EffectType.HEAL)

