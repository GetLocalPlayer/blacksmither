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


@export var effect_value: float = 20:
	set(value):
		effect_value = value if value >= 0. else 0.


enum CastType {MELEE, RANGED}
## Defines if the character must approach the target
@export var cast_type: CastType = CastType.MELEE

enum AllowedTargets {
	ENEMY = 1,
	ALLY = 1 << 1,
	SELF = 1 << 2,
	ALIVE = 1 << 3,
	DEAD = 1 << 4,
}
@export var allowed_targets: AllowedTargets = AllowedTargets.ENEMY | AllowedTargets.ALIVE


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"allowed_targets":
			property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CLASS_IS_BITFIELD
			property.hint = PROPERTY_HINT_FLAGS 


func is_target_valid(caster: CombatCharacter, target: CombatCharacter) -> bool:
	# Can't use the ability if it can be used on neither alive nor dead
	if not (allowed_targets & (AllowedTargets.ALIVE | AllowedTargets.DEAD)):
		return false
	# Only alive targets
	if not (allowed_targets & AllowedTargets.DEAD) and (allowed_targets & AllowedTargets.ALIVE) and target.is_dead():
		return false
	# Only dead targets
	if not (allowed_targets & AllowedTargets.ALIVE) and (allowed_targets & AllowedTargets.DEAD) and target.is_alive():
		return false
	if allowed_targets & AllowedTargets.SELF and target == caster:
		return true
	if allowed_targets & AllowedTargets.ALLY and target.ally_layers & caster.ally_layers:
		return true
	if allowed_targets & AllowedTargets.ENEMY and not target.ally_layers & caster.ally_layers:
		return true
	return false


func apply(target: CombatCharacter) -> void:
	match effect_type:
		EffectType.DAMAGE:
			target.take_damage(effect_value)
			print("damage ability")