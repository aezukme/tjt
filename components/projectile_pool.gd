class_name ProjectilePool
extends Node

## Object pool for projectile instances to avoid constant instantiate/queue_free.
## Usage: ProjectilePool.get_instance().acquire(scene) → returns a node
##        When projectile finishes → call ProjectilePool.get_instance().release(node)

const MAX_POOL_SIZE := 20  ## Max idle projectiles per scene type

## Singleton access via group
static func get_instance() -> ProjectilePool:
	var tree := Engine.get_main_loop() as SceneTree
	if not tree:
		return null
	var nodes := tree.get_nodes_in_group("projectile_pool")
	if nodes.is_empty():
		return null
	return nodes[0] as ProjectilePool


## Pool storage: scene_path → Array of idle Projectile nodes
var _pools: Dictionary = {}
## Track active count for debug
var _active_count: int = 0


func _ready() -> void:
	add_to_group("projectile_pool")


## Acquire a projectile from the pool (or instantiate a new one).
func acquire(scene: PackedScene) -> Node:
	var key: String = scene.resource_path
	if not _pools.has(key):
		_pools[key] = []

	var pool: Array = _pools[key]

	# Reuse from pool if available
	if not pool.is_empty():
		var recycled: Node = pool.pop_back()
		if is_instance_valid(recycled):
			recycled.visible = true
			recycled.set_process(true)
			_active_count += 1
			# Reparent to the current scene so it behaves like a normal active node
			var tree := Engine.get_main_loop() as SceneTree
			if tree and tree.current_scene and recycled.get_parent() != tree.current_scene:
				var old_parent := recycled.get_parent()
				if old_parent and is_instance_valid(old_parent):
					old_parent.remove_child(recycled)
				tree.current_scene.add_child(recycled)
			# Reset instance state if available
			if recycled.has_method("reset"):
				recycled.reset()
			return recycled

	# Create new
	var projectile: Node = scene.instantiate()
	# Parent new projectiles into the current scene for normal processing/rendering
	var tree := Engine.get_main_loop() as SceneTree
	if tree and tree.current_scene:
		tree.current_scene.add_child(projectile)
	else:
		add_child(projectile)
	_active_count += 1
	return projectile


## Return a projectile to the pool instead of freeing it.
func release(projectile: Node, scene: PackedScene) -> void:
	if not is_instance_valid(projectile):
		return

	var key: String = scene.resource_path
	if not _pools.has(key):
		_pools[key] = []

	var pool: Array = _pools[key]
	_active_count -= 1

	# If pool is full, actually free it
	if pool.size() >= MAX_POOL_SIZE:
		projectile.queue_free()
		return

	# Reset, hide and reparent back into the pool node
	projectile.visible = false
	projectile.set_process(false)
	# Clear runtime state if present
	if projectile.has_method("reset"):
		projectile.reset()
	projectile.is_setup = false
	# Reparent into this pool node so it stays organized
	if projectile.get_parent() != self:
		var prev_parent := projectile.get_parent()
		if prev_parent and is_instance_valid(prev_parent):
			prev_parent.remove_child(projectile)
		add_child(projectile)
	pool.append(projectile)
