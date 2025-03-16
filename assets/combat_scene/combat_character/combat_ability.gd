@tool
extends Node
class_name CombatAbility


@export var icon: CompressedTexture2D = null
@export var title: String = "Empty Name"
@export var description: String = "Empty Description"


enum EffectType {DAMAGE, HEAL}

@export var requires_target: bool = true
					

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


enum CastType {MELEE, RANGED}
## Defines if the character must approach the target
@export var cast_type: CastType = CastType.MELEE

@export_subgroup("Allowed Targets")
enum AllowedTargets {
	ENEMY = 1,
	ALLY = 1 << 1,
	SELF = 1 << 2,
}
@export var allowed_targets: AllowedTargets = AllowedTargets.ENEMY

@export_subgroup("Animations")
## Animation that is used before cast animation.
## For abilities with `requires_target` set to
## true, the animation is played when the ability
## is awaiting the target.
@export var prepare_anim: String = "prepare"
## Cast animation. For CastType.MELEE the animation
## is played when the character is moving towards
## the target.
@export var cast_anim: String = "cast"
## The animation that is played when the ability
## applys its effect on the target.
@export var impact_anim: String = "impact"


func _validate_property(property: Dictionary) -> void:
	var validate_effect_type = func validate_effect_type(et: EffectType) -> int:
		return PROPERTY_USAGE_DEFAULT if effect_type == et else PROPERTY_USAGE_DEFAULT ^ PROPERTY_USAGE_EDITOR

	match property.name:
		"damage":
			property.usage = validate_effect_type.call(EffectType.DAMAGE)
		"heal":
			property.usage = validate_effect_type.call(EffectType.HEAL)
		"allowed_targets":
			property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CLASS_IS_BITFIELD
			property.hint = PROPERTY_HINT_FLAGS


func apply(caster: CombatCharacter, target: CombatCharacter) -> void:
	if requires_target:
		caster.to_target = target.global_position
		while not target in caster.get_overlapping_areas():
			await caster.area_entered
		caster.to_target = null
