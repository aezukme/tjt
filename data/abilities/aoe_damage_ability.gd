extends Ability
class_name AOEDamageAbility

## AOE Damage ability - damages all enemies

@export var damage: float = 25.0


func execute(caster: Unit, targets: Array) -> void:
	if targets.is_empty():
		return
	
	# Spawn VFX at caster position
	var vfx_spawner = caster.get_tree().get_first_node_in_group("vfx_spawner")
	if vfx_spawner and vfx_spawner.has_method("spawn_vfx"):
		vfx_spawner.spawn_vfx("explosion_magic", caster.global_position)
	
	# Damage all targets
	for target in targets:
		if not is_instance_valid(target):
			continue
		if target.has_method("apply_damage"):
			target.apply_damage(int(damage), UnitStats.DamageType.MAGICAL)
		elif "current_health" in target:
			target.current_health -= damage
		else:
			target.stats.health = maxi(target.stats.health - int(damage), 0)
		if target.has_method("flash_skin"):
			target.flash_skin(Color.PURPLE)
		# Spawn hit VFX on each target
		if vfx_spawner and vfx_spawner.has_method("spawn_vfx_on_unit"):
			vfx_spawner.spawn_vfx_on_unit("explosion_magic", target)
	
	caster.flash_skin(Color.PURPLE)
