class_name UnitAI
extends Node

## Emitted when unit reaches target
signal movement_finished
## Emitted when unit attacks
signal attack_performed(target)

## Toggle AI debug logging (set to true to see pathfinding/targeting/movement logs)
const DEBUG_AI: bool = true

const CELL_SIZE := Vector2(32, 32)
const HALF_CELL_SIZE := Vector2(16, 16)

@export var enabled: bool = false
@export var update_interval: float = 0.5  ## How often AI updates (performance)

var unit
var current_target
var path: Array[Vector2i] = []
var current_path_index: int = 0
var movement_speed: float = 100.0  ## Pixels per second
var attack_timer: float = 0.0
var update_timer: float = 0.0

## Reference to play areas for pathfinding
var play_area: PlayArea
var enemy_area: PlayArea
var navigation_agent: NavigationAgent2D


## Called when the node enters the scene tree.
func _ready() -> void:
	unit = get_parent()
	assert(unit, "UnitAI must be a child of Unit!")
	
	navigation_agent = unit.get_node_or_null("NavigationAgent2D")
	
	# Find play areas from the scene
	_find_play_areas()
	
	# Initialize stats
	if unit.stats:
		# Combat movement speed - balanced for visible but quick movement
		movement_speed = 50.0  # pixels per second
	
	# Connect navigation signals if available
	if navigation_agent:
		navigation_agent.velocity_computed.connect(_on_velocity_computed)


## Process AI logic.
func _process(delta: float) -> void:
	if not enabled or not unit or not unit.stats:
		return
	
	# Don't run AI when not in BATTLE state
	var bm = get_tree().get_first_node_in_group("battle_manager")
	if bm and bm.current_state != BattleManager.State.BATTLE:
		return
	
	update_timer -= delta
	if update_timer <= 0:
		update_timer = update_interval
		_update_ai()
	
	# Update attack cooldown
	if attack_timer > 0:
		attack_timer -= delta
	
	# Separation logic - push units away from each other to prevent overlap
	_apply_separation(delta)
	
	# Attempt attack if in range and cooldown ready
	if current_target and is_instance_valid(current_target):
		var distance_to_target: float = unit.global_position.distance_to(current_target.global_position)
		var attack_range_pixels: float = unit.stats.attack_range * CELL_SIZE.x
		
		if distance_to_target <= attack_range_pixels and attack_timer <= 0:
			# In range and ready to attack
			_try_attack()
		elif distance_to_target > attack_range_pixels and (not current_target.has_meta("is_dummy_target") or unit.stats.team == UnitStats.Team.ENEMY):
			# Out of range - move closer
			if navigation_agent:
				# Use navigation pathfinding
				navigation_agent.target_position = current_target.global_position
				var next_position = navigation_agent.get_next_path_position()
				var direction = (next_position - unit.global_position).normalized()
				var distance_to_move = movement_speed * delta
				if unit.global_position.distance_to(next_position) > distance_to_move:
					unit.global_position += direction * distance_to_move
			else:
				# Direct movement
				var direction: Vector2 = (current_target.global_position - unit.global_position).normalized()
				var distance_to_move: float = movement_speed * delta
				unit.global_position += direction * distance_to_move
			if DEBUG_AI and update_timer <= 0:
				var target_name = current_target.stats.name if ("stats" in current_target and current_target.stats) else "[dummy]"
				print("[AI] %s: moving → %s (dist=%.0fpx, range=%.0fpx, speed=%.0f)" % [unit.stats.name, target_name, distance_to_target, attack_range_pixels, movement_speed])


## Main AI update logic.
func _update_ai() -> void:
	# Find or update target
	var new_target = _find_nearest_enemy()
	
	# For enemy units, if no target, they should move towards player base
	if not new_target and unit.stats.team == UnitStats.Team.ENEMY:
		new_target = _get_player_base_target()
	
	# If target changed, clean up old dummy target
	if current_target != new_target:
		if DEBUG_AI:
			var old_name = "none"
			var new_name = "none"
			if current_target and is_instance_valid(current_target) and "stats" in current_target and current_target.stats:
				old_name = current_target.stats.name
			elif current_target and current_target.has_meta("is_dummy_target"):
				old_name = "[dummy]"
			if new_target and is_instance_valid(new_target) and "stats" in new_target and new_target.stats:
				new_name = new_target.stats.name
			elif new_target and new_target.has_meta("is_dummy_target"):
				new_name = "[dummy]"
			print("[AI] %s: target changed %s → %s" % [unit.stats.name, old_name, new_name])
		if current_target and current_target.has_meta("is_dummy_target"):
			current_target.queue_free()
		current_target = new_target


## Finds the nearest enemy unit within aggro range.
func _find_nearest_enemy():
	if not unit.stats:
		return null
	
	var target_group: String = UnitStats.TARGET[unit.stats.team]
	var enemies := get_tree().get_nodes_in_group(target_group)
	
	if enemies.is_empty():
		if DEBUG_AI:
			print("[AI] %s: no enemies in group '%s'" % [unit.stats.name, target_group])
		return null
	
	var nearest = null
	var nearest_distance := INF
	var aggro_range_pixels: float = unit.stats.aggro_range * CELL_SIZE.x
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		# Skip self
		if enemy == unit:
			continue
		
		var distance: float = unit.global_position.distance_to(enemy.global_position)
		
		# Check if within aggro range
		if distance <= aggro_range_pixels:
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = enemy
	
	if DEBUG_AI:
		if nearest and "stats" in nearest and nearest.stats:
			print("[AI] %s: found target %s (dist=%.0fpx, aggro=%.0fpx, enemies=%d)" % [unit.stats.name, nearest.stats.name, nearest_distance, aggro_range_pixels, enemies.size()])
		else:
			print("[AI] %s: no enemy within aggro range %.0fpx (enemies=%d)" % [unit.stats.name, aggro_range_pixels, enemies.size()])
	
	return nearest


## Returns a dummy target representing the player base for enemy units.
## NOTE: The returned dummy node is added to the scene tree so it can be freed
## properly when the target changes (see _update_ai).
func _get_player_base_target():
	var dummy = Node2D.new()
	dummy.global_position = Vector2(unit.global_position.x, 1000)  # Far below
	dummy.set_meta("is_dummy_target", true)
	unit.get_tree().current_scene.add_child(dummy)
	return dummy


## Moves towards the current target.

## Performs an attack on the target.
func _move_along_path(delta: float) -> void:
	if path.is_empty() or current_path_index >= path.size():
		path.clear()
		movement_finished.emit()
		return
	
	var target_tile := path[current_path_index]
	var target_pos := play_area.get_global_from_tile(target_tile) - HALF_CELL_SIZE
	
	var direction: Vector2 = (target_pos - unit.global_position).normalized()
	var move_distance: float = movement_speed * delta
	
	if unit.global_position.distance_to(target_pos) <= move_distance:
		# Reached waypoint
		unit.global_position = target_pos
		current_path_index += 1
		
		if current_path_index >= path.size():
			path.clear()
			movement_finished.emit()
	else:
		# Move towards waypoint
		unit.global_position += direction * move_distance


## Attempts to attack the current target.
func _try_attack() -> void:
	if not current_target or not is_instance_valid(current_target):
		return
	
	if attack_timer > 0:
		return  # Still on cooldown
	
	# Don't attack dummy targets (like player base)
	if not current_target.has_meta("is_dummy_target"):
		_perform_attack(current_target)
		# Set cooldown
		if unit.stats:
			attack_timer = unit.stats.get_time_between_attacks()


## Performs an attack on the target.
func _perform_attack(target) -> void:
	if not target or not target.stats:
		return

	# Prevent unit from attacking itself
	if target == unit:
		return

	# Calculate damage
	var damage: int = unit.stats.get_attack_damage()

	if DEBUG_AI:
		var target_hp = target.current_health if "current_health" in target else target.stats.health
		print("[AI] %s: ⚔ attacks %s for %d dmg (target HP: %d → %d)" % [unit.stats.name, target.stats.name, damage, int(target_hp), int(max(target_hp - damage, 0))])

	# Apply damage using a common method if available, otherwise fallback to stats
	if UnitUtils.is_unit_node(target):
		target.apply_damage(damage)
	else:
		# Fallback: adjust resource health which will emit signals
		if target.stats:
			target.stats.health = max(target.stats.health - damage, 0)

	attack_performed.emit(target)

	# Flash attacker
	_flash_unit(unit)
	# Flash target (will be red from health bar flash already)
	_flash_unit(target, Color.RED)


## A* pathfinding on the unit grid.
## Returns an ordered list of tiles from start to goal, avoiding occupied tiles.
## Uses Manhattan distance as heuristic (no diagonal movement).
func _find_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if not play_area or not play_area.unit_grid:
		return result

	var grid_size: Vector2i = play_area.unit_grid.size

	# If goal is out of bounds, clamp it to nearest valid tile
	var clamped_goal := Vector2i(
		clampi(goal.x, 0, grid_size.x - 1),
		clampi(goal.y, 0, grid_size.y - 1)
	)

	# If start equals goal, nothing to do
	if start == clamped_goal:
		return result

	# A* data structures
	# open_set: priority queue as Array of [f_score, tile]
	var open_set: Array = [[_heuristic(start, clamped_goal), start]]
	var came_from: Dictionary = {}  # tile -> parent tile
	var g_score: Dictionary = {start: 0}  # tile -> cost from start
	var closed_set: Dictionary = {}  # tile -> true

	# Directions: up, down, left, right (no diagonals for grid movement)
	var directions: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(0, 1), Vector2i(0, -1)
	]

	var max_iterations := grid_size.x * grid_size.y * 2  # Safety limit
	var iterations := 0

	while not open_set.is_empty() and iterations < max_iterations:
		iterations += 1

		# Find node with lowest f_score (simple linear scan — grid is small)
		var best_idx := 0
		for i in range(1, open_set.size()):
			if open_set[i][0] < open_set[best_idx][0]:
				best_idx = i

		var current_entry = open_set[best_idx]
		var current: Vector2i = current_entry[1]
		open_set.remove_at(best_idx)

		# Reached the goal — reconstruct path
		if current == clamped_goal:
			var path_tile := current
			while path_tile != start:
				result.insert(0, path_tile)
				path_tile = came_from[path_tile]
			return result

		closed_set[current] = true

		# Explore neighbors
		for dir in directions:
			var neighbor: Vector2i = current + dir

			# Bounds check
			if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= grid_size.x or neighbor.y >= grid_size.y:
				continue

			# Already evaluated
			if closed_set.has(neighbor):
				continue

			# Occupied check (skip goal tile — we want to path TO it even if occupied by enemy)
			if neighbor != clamped_goal:
				if play_area.unit_grid.units.has(neighbor) and play_area.unit_grid.is_tile_occupied(neighbor):
					continue

			var tentative_g: int = g_score[current] + 1

			if not g_score.has(neighbor) or tentative_g < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				var f: int = tentative_g + _heuristic(neighbor, clamped_goal)
				open_set.append([f, neighbor])

	# No path found — return empty (unit will use direct movement fallback)
	return result


## Manhattan distance heuristic for A*.
func _heuristic(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


## Finds the play areas from the scene tree.
func _find_play_areas() -> void:
	# Get arena node
	var arena := get_tree().get_first_node_in_group("arena")
	if not arena:
		print("ERROR: Could not find Arena node in group 'arena'!")
		return
	
	# Find play areas based on unit's team
	if unit.stats:
		if unit.stats.team == UnitStats.Team.PLAYER:
			play_area = arena.get_node_or_null("GameArea")
			enemy_area = arena.get_node_or_null("EnemyArea")
		else:
			play_area = arena.get_node_or_null("EnemyArea")
			enemy_area = arena.get_node_or_null("GameArea")


## Flashes a unit sprite with a color for visual feedback.
func _flash_unit(target_unit, color: Color = Color.WHITE) -> void:
	if target_unit and target_unit.has_method("flash_skin"):
		target_unit.flash_skin(color)
	else:
		# Fallback for units without flash_skin method
		if not target_unit or not target_unit.has_node("Visuals/Skin"):
			return
		
		var skin = target_unit.get_node("Visuals/Skin")
		var original_color = skin.modulate
		skin.modulate = color
		
		# Reset color after short delay
		await get_tree().create_timer(0.08).timeout
		if is_instance_valid(skin):
			skin.modulate = original_color


## Apply separation force to avoid unit overlap.
func _apply_separation(delta: float) -> void:
	if not unit or not unit.stats:
		return
	
	var min_distance: float = 40.0  # Minimum distance between units (slightly more than 1 tile)
	var separation_force: float = 200.0  # Force to push apart
	
	var all_units = get_tree().get_nodes_in_group("units")
	var separation_vector: Vector2 = Vector2.ZERO
	var neighbor_count: int = 0
	
	for other_unit in all_units:
		if other_unit == unit or not is_instance_valid(other_unit) or not other_unit.stats:
			continue
		
		# Only separate from allies, not enemies
		if other_unit.stats.team != unit.stats.team:
			continue
		
		var distance: float = unit.global_position.distance_to(other_unit.global_position)
		if distance < min_distance and distance > 0.1:
			# Calculate separation direction (away from other unit)
			var direction: Vector2 = (unit.global_position - other_unit.global_position).normalized()
			var strength: float = 1.0 - (distance / min_distance)  # Stronger when closer
			separation_vector += direction * strength
			neighbor_count += 1
	
	# Apply separation if there are neighbors
	if neighbor_count > 0:
		separation_vector = separation_vector.normalized()
		var push_distance: float = separation_force * delta
		unit.global_position += separation_vector * push_distance


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	# Apply computed velocity from navigation
	unit.global_position += safe_velocity * get_process_delta_time()
