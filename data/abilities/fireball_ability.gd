extends Ability
class_name FireballAbility

## Fireball ability - deals damage to a single enemy

@export var damage: float = 50.0

const ProjectileScene = preload("res://scenes/projectile/projectile.tscn")


func execute(caster: Unit, targets: Array) -> void:
	if targets.is_empty():
		print("[Fireball] No valid targets!")
		return
	
	# Pick best target — prefer enemies not already overkilled on paper
	var target = targets[0]
	if target_type == TargetType.SINGLE_ENEMY and targets.size() > 1:
		target = _get_best_target(caster, targets)
	
	# Register incoming damage BEFORE projectile spawns so other casters see it
	if target.has_method("get_effective_health"):
		target.incoming_damage += damage
	
	print("[Fireball] %s casts Fireball on %s for %d damage! (effective HP: %.0f)" % [
		caster.stats.name, target.stats.name, damage,
		target.get_effective_health() if target.has_method("get_effective_health") else -1.0])
	
	# Spawn projectile
	_spawn_projectile(caster, target)


func _get_best_target(caster: Unit, targets: Array) -> Node:
	# Pass 1: Find closest enemy that isn't already overkilled on paper
	var best: Node = null
	var best_dist: float = INF
	# Pass 2 fallback: plain closest (in case ALL are overkilled)
	var fallback: Node = targets[0]
	var fallback_dist: float = caster.global_position.distance_to(fallback.global_position)
	
	for target in targets:
		var dist: float = caster.global_position.distance_to(target.global_position)
		# Track plain closest for fallback
		if dist < fallback_dist:
			fallback = target
			fallback_dist = dist
		# Prefer targets with effective HP > 0 (not overkilled)
		if target.has_method("get_effective_health") and target.get_effective_health() > 0.0:
			if dist < best_dist:
				best = target
				best_dist = dist
	
	return best if best != null else fallback


func _spawn_projectile(caster, target) -> void:
	if not ProjectileScene:
		_apply_direct_hit(target)
		return

	# Use object pool if available, otherwise instantiate directly
	var pool_nodes = caster.get_tree().get_nodes_in_group("projectile_pool")
	var projectile: Node
	if not pool_nodes.is_empty() and is_instance_valid(pool_nodes[0]):
		projectile = pool_nodes[0].acquire(ProjectileScene)
	else:
		projectile = ProjectileScene.instantiate()
		caster.get_tree().current_scene.add_child(projectile)

	projectile.global_position = caster.global_position
	# Ensure the projectile instance has the runtime script available; attach if missing.
	if not projectile.has_method("setup"):
		var proj_script = load("res://scenes/projectile/projectile.gd")
		if proj_script:
			projectile.set_script(proj_script)

	# Call setup if available, otherwise fallback to direct hit
	if projectile.has_method("setup"):
		projectile.setup(caster, target, damage, Color.ORANGE_RED)
		return

	# If the instantiated scene lacks the script (missing ext_resource), try to attach it.
	var proj_script = load("res://scenes/projectile/projectile.gd")
	if proj_script:
		# Attach the script to the instance and retry setup
		projectile.set_script(proj_script)
		if projectile.has_method("setup"):
			projectile.setup(caster, target, damage, Color.ORANGE_RED)
			return

	push_warning("[Fireball] Projectile scene is missing setup(); applying direct damage.")
	_apply_direct_hit(target)
	if is_instance_valid(projectile):
		projectile.queue_free()


func _apply_direct_hit(target: Node) -> void:
	if not target:
		return

	if target.has_method("apply_damage"):
		target.apply_damage(damage)
	elif target is Unit:
		target.current_health = max(target.current_health - damage, 0)

	if target.has_method("flash_skin"):
		target.flash_skin(Color.ORANGE_RED)
