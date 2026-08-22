extends Ability
class_name AoEHealAbility

## AoE Heal ability - heals all allies in range

@export var heal_amount: float = 40.0


func execute(caster: Unit, targets: Array) -> void:
	if targets.is_empty():
		return

	var healed_count: int = 0
	for target in targets:
		if not is_instance_valid(target):
			continue
		# Only heal allies that are actually wounded
		var current_hp: float = target.current_health if "current_health" in target else target.stats.health
		var max_hp: float = target.stats.max_health
		if current_hp >= max_hp:
			continue

		var actual_heal: float = minf(heal_amount, max_hp - current_hp)
		if "current_health" in target:
			target.current_health = minf(target.current_health + actual_heal, max_hp)
		else:
			target.stats.health = mini(int(target.stats.health + actual_heal), int(max_hp))

		# Register incoming healing for anti-overheal
		if "incoming_healing" in target:
			target.incoming_healing += actual_heal

		if target.has_method("flash_skin"):
			target.flash_skin(Color.GREEN)
		healed_count += 1

	caster.flash_skin(Color.GREEN)
