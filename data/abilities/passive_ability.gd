extends Resource
class_name PassiveAbility

## Base class for passive abilities that modify unit stats

enum PassiveType {
	HEALTH_REGEN_BONUS,    # Increases health regen by percentage
	MANA_REGEN_BONUS,      # Increases mana regen by percentage
	DAMAGE_BONUS,          # Increases attack damage
	ARMOR_BONUS,           # Increases armor
	SPEED_BONUS,           # Increases attack speed
	MAX_HEALTH_BONUS,      # Increases max health
	DAMAGE_REDUCTION       # Reduces every incoming hit by a flat amount (after armor/MR), min 1 dmg
}

## Floor for DAMAGE_REDUCTION — a hit can never be reduced to zero so no unit is fully immune.
const MIN_DAMAGE_AFTER_REDUCTION: int = 1

@export var passive_name: String = "Unnamed Passive"
@export_multiline var description: String = ""
@export var passive_type: PassiveType = PassiveType.HEALTH_REGEN_BONUS
@export var value: float = 0.0  # Percentage (0.2 = 20%) or flat value depending on type


## Apply passive effect to unit
func apply(unit: Unit) -> void:
	match passive_type:
		PassiveType.HEALTH_REGEN_BONUS:
			# Increase health regen by percentage
			var bonus = unit.stats.health_regen * value
			unit.stats.health_regen += bonus
		
		PassiveType.MANA_REGEN_BONUS:
			var bonus = unit.stats.mana_regen * value
			unit.stats.mana_regen += bonus
		
		PassiveType.DAMAGE_BONUS:
			var bonus = int(unit.stats.attack_damage * value)
			unit.stats.attack_damage += bonus
		
		PassiveType.ARMOR_BONUS:
			var bonus = int(value)
			unit.stats.armor += bonus
		
		PassiveType.MAX_HEALTH_BONUS:
			var bonus = int(unit.stats.max_health * value)
			unit.stats.max_health += bonus
			unit.current_health += bonus  # Also increase current health
		
		PassiveType.DAMAGE_REDUCTION:
			# Nothing to bake into stats — evaluated per hit via modify_incoming_damage().
			print("[Passive] %s: %s gains flat -%d damage per hit" % [unit.stats.name, passive_name, int(value)])


## Applies per-hit modifiers to damage that has already been reduced by armor/MR.
## Deterministic on purpose (no chance rolls) — see GDD Pillar 6 "No RNG should decide a match".
func modify_incoming_damage(damage: int) -> int:
	if passive_type != PassiveType.DAMAGE_REDUCTION or damage <= 0:
		return damage
	return maxi(damage - int(value), MIN_DAMAGE_AFTER_REDUCTION)


## Remove passive effect from unit (for temporary passives)
func remove(unit: Unit) -> void:
	match passive_type:
		PassiveType.HEALTH_REGEN_BONUS:
			var bonus = (unit.stats.health_regen / (1.0 + value)) * value
			unit.stats.health_regen -= bonus
		
		PassiveType.MANA_REGEN_BONUS:
			var bonus = (unit.stats.mana_regen / (1.0 + value)) * value
			unit.stats.mana_regen -= bonus
		
		PassiveType.DAMAGE_BONUS:
			var bonus = int((unit.stats.attack_damage / (1.0 + value)) * value)
			unit.stats.attack_damage -= bonus
		
		PassiveType.ARMOR_BONUS:
			unit.stats.armor -= int(value)
		
		PassiveType.MAX_HEALTH_BONUS:
			var bonus = int((unit.stats.max_health / (1.0 + value)) * value)
			unit.stats.max_health -= bonus
