@tool
extends TextureButton
class_name Ability


enum CastType {TARGET, INSTANT}
enum EffectType {DAMAGE, HEALING}

@export var cast_type: CastType = CastType.TARGET
@export var effect_type: EffectType = EffectType.DAMAGE:
	get:
		return effect_type
	set(value):
		effect_type = value
		if Engine.is_editor_hint():
			notify_property_list_changed()


var _properties: Dictionary = {
	EffectType.DAMAGE: {	
		name = "Damage",
		type = TYPE_FLOAT,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0,1000,1",
		value = 100,
		default = 100,
	},
	EffectType.HEALING: {
		name = "Healing",
		type = TYPE_FLOAT,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0,1000,1",
		value = 100,
		default = 100,
	}
}


func _property_can_revert(property: StringName) -> bool:
	for p in _properties:
		if p.name == property:
			return true
	return false

func _get_property_list() -> Array[Dictionary]:
	return [_properties[effect_type]]
