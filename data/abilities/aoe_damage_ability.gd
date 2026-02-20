extends Ability
class_name AOEDamageAbility

## AOE Damage ability - damages all enemies

@export var damage: float = 25.0


func execute(caster: Unit, targets: Array) -> void:
	if targets.is_empty():
		print("[AOE] No valid targets!")
		return
	
	print("[AOE] %s casts AOE attack, hitting %d enemies!" % [caster.stats.name, targets.size()])
	
	# Damage all targets
	for target in targets:
		if not is_instance_valid(target):
			continue
		if target.has_method("apply_damage"):
			target.apply_damage(int(damage))
		elif "current_health" in target:
			target.current_health -= damage
		else:
			target.stats.health = maxi(target.stats.health - int(damage), 0)
		if target.has_method("flash_skin"):
			target.flash_skin(Color.PURPLE)
	
	# Visual effect (TODO: spawn area particle effect)
	caster.flash_skin(Color.PURPLE)
