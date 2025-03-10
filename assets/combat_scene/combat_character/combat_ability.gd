@tool
extends TextureButton
class_name CombatAbility


@export var title: String = "Empty Name"
@export var description: String = "Empty Description"


enum CastType {TARGET, INSTANT}
enum EffectType {DAMAGE, HEAL}

@export var cast_type: CastType = CastType.TARGET:
	get:
		return cast_type
	set(value):
		cast_type = value
		if is_node_ready():
			match value:
				CastType.TARGET:
					toggle_mode = true
				CastType.INSTANT:
					toggle_mode = false
					

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

@export_subgroup("Available Targets")
enum TargetType {
	ENEMY = 1,
	ALLY = 1 << 1,
	SELF = 1 << 2,
}
@export var target_type: TargetType = TargetType.ENEMY


func _validate_property(property: Dictionary) -> void:
	var validate_effect_type = func(et: EffectType) -> int:
		return PROPERTY_USAGE_DEFAULT if effect_type == et else PROPERTY_USAGE_DEFAULT ^ PROPERTY_USAGE_EDITOR

	if property.name == "damage":
		property.usage = validate_effect_type.call(EffectType.DAMAGE)
	if property.name == "heal":
		property.usage = validate_effect_type.call(EffectType.HEAL)
	if property.name == "target_type":
		property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CLASS_IS_BITFIELD
		property.hint = PROPERTY_HINT_FLAGS


func _ready() -> void:
	hide()