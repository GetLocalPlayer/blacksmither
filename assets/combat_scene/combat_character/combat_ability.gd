@tool
extends Node
class_name CombatAbility


signal progress_changed


@export var icon: CompressedTexture2D = null:
	get = get_icon, set = set_icon


func get_icon() -> CompressedTexture2D:
	return icon

func set_icon(new_icon: CompressedTexture2D) -> void:
	icon = new_icon


@export var title: String = "Empty Name"
@export var description: String = "Empty Description"


enum EffectType {DAMAGE, HEAL}

@export var requires_target: bool = true
					

enum CastType {MELEE, RANGED}
## Ближний или дальний. Если ближний, то персонаж
## сначала подойдет к цели.
@export var cast_type: CastType = CastType.MELEE

enum AllowedTargets {
	ENEMY = 1,
	ALLY = 1 << 1,
	SELF = 1 << 2,
	ALIVE = 1 << 3,
	DEAD = 1 << 4,
}

@export var allowed_targets: int = AllowedTargets.ENEMY | AllowedTargets.ALIVE


## Прогресс бар который отображается под иконкой.
## Может отражать оставшуюся прочность оружия, заряд
## или что-то еще.
@export var show_progress: bool = false

# Переопределяется в потомках
var progress: float = 0:
	set(value):
		progress = value
		progress_changed.emit()


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"allowed_targets":
			property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CLASS_IS_BITFIELD
			property.hint = PROPERTY_HINT_FLAGS 
			property.hint_string = ",".join(AllowedTargets.keys())


func is_target_valid(caster: CombatCharacter, target: CombatCharacter) -> bool:
	# Can't use the ability if it can be used on neither alive nor dead
	if not (allowed_targets & (AllowedTargets.ALIVE | AllowedTargets.DEAD)):
		return false
	# Только живые цели
	if not (allowed_targets & AllowedTargets.DEAD) and (allowed_targets & AllowedTargets.ALIVE) and target.is_dead():
		return false
	# Только мертвые цели 
	if not (allowed_targets & AllowedTargets.ALIVE) and (allowed_targets & AllowedTargets.DEAD) and target.is_alive():
		return false
	if allowed_targets & AllowedTargets.SELF and target == caster:
		return true
	if allowed_targets & AllowedTargets.ALLY and target.ally_layers & caster.ally_layers:
		return true
	if allowed_targets & AllowedTargets.ENEMY and not target.ally_layers & caster.ally_layers:
		return true
	return false


# Переопределяется в потомках
func apply(_target: CombatCharacter) -> void:
	pass
