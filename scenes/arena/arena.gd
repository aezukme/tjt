class_name Arena
extends Node2D

const CELL_SIZE := Vector2(32, 32)
const HALF_CELL_SIZE := Vector2(16, 16)
const QUARTER_CELL_SIZE := Vector2(8, 8)

const VICTORY_SCENE := "res://scenes/menu/victory_screen.tscn"
const GAME_OVER_SCENE := "res://scenes/menu/game_over_screen.tscn"
const END_SCREEN_DELAY := 1.5  ## Seconds before transitioning to end screen

@export var player_stats: PlayerStats

@onready var unit_mover: UnitMover = $UnitMover
@onready var unit_spawner: UnitSpawner = $UnitSpawner
@onready var battle_manager: BattleManager = $BattleManager
@onready var unit_stats_container: VBoxContainer = $UI/UnitStatsContainer
@onready var start_battle_button: Button = $UI/RightPanel/StartBattleButton
@onready var toggle_units_button: Button = $UI/RightPanel/ToggleUnitsButton
@onready var enemy_area: PlayArea = $EnemyArea
@onready var game_area: PlayArea = $GameArea
@onready var unit_selection_panel = $UI/UnitSelectionPanel

# LEGACY: Old enemy wave spawn system - kept for compatibility
# Now using WaveManager system instead
@export var enemy_wave := []
@export_range(1, 3) var enemy_spawn_batch_size: int = 1
@export var enemy_spawn_interval: float = 0.45

# Wave system
var wave_manager: Node

# Placement mode state
var _placement_stats: UnitStats = null  ## The unit type being placed (null = not in placement mode)
var _placement_ghost: Sprite2D = null  ## Ghost sprite following the cursor
var _drag_placing: bool = false  ## True when placing via card drag (release to place)

# Camera zoom
const ZOOM_MIN := 0.5
const ZOOM_MAX := 2.0
const ZOOM_STEP := 0.1
@onready var camera: Camera2D = $Camera2D

# Camera pan (middle mouse)
var _camera_panning := false
var _camera_pan_start := Vector2.ZERO

## Called when the node enters the scene tree. Connects unit spawner to unit mover.
func _ready() -> void:
	# Add ProjectilePool if one doesn't already exist
	if not get_tree().get_first_node_in_group("projectile_pool"):
		var pool = Node.new()
		pool.name = "ProjectilePool"
		pool.set_script(load("res://components/projectile_pool.gd"))
		add_child(pool)

	unit_spawner.unit_spawned.connect(unit_mover.setup_unit)
	
	# Connect battle manager signals
	battle_manager.battle_started.connect(_on_battle_started)
	battle_manager.battle_ended.connect(_on_battle_ended)
	battle_manager.preparation_started.connect(_on_preparation_started)
	battle_manager.state_changed.connect(_on_battle_state_changed)

	# Connect UI button
	if start_battle_button:
		start_battle_button.pressed.connect(_on_start_battle_pressed)
		# initial state based on current battle manager state
		_on_battle_state_changed(battle_manager.current_state)
	
	# Get or find wave manager
	wave_manager = get_node_or_null("WaveManager")
	if not wave_manager:
		wave_manager = get_tree().get_first_node_in_group("wave_manager")

	# Connect wave manager signals for end-game transitions
	if wave_manager:
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	# ── Unit Selection Panel ──
	if unit_selection_panel:
		unit_selection_panel.unit_selected.connect(_on_panel_unit_selected)
		unit_selection_panel.unit_drag_started.connect(_on_panel_unit_drag_started)
		unit_selection_panel.placement_cancelled.connect(_on_placement_cancelled)
		# Count pre-placed player units
		var preplaced := get_tree().get_nodes_in_group("player_units")
		unit_selection_panel.deployed_count = preplaced.size()
		# Start with panel hidden
		unit_selection_panel.visible = false
		# Wire player stats for gold tracking
		if player_stats:
			unit_selection_panel.set_player_stats(player_stats)

	# Toggle button for unit panel
	if toggle_units_button:
		toggle_units_button.pressed.connect(_on_toggle_units_pressed)

	# ── Spawn King ──
	_spawn_king()


## Spawns the King unit at the bottom-center of the GameArea.
func _spawn_king() -> void:
	var king_stats: UnitStats = load("res://data/units/king_ally.tres")
	if not king_stats:
		push_warning("[Arena] Could not load king_ally.tres!")
		return
	# Place at bottom-center of the game area
	var grid_size: Vector2i = game_area.unit_grid.size
	var king_tile := Vector2i(int(grid_size.x / 2), grid_size.y - 1)
	# Find a free tile near bottom-center
	if game_area.unit_grid.is_tile_occupied(king_tile):
		king_tile = game_area.unit_grid.get_first_available_tile()
	var king_node := unit_spawner.spawn_unit(king_stats, king_tile)
	if king_node:
		# King doesn't count toward deployed limit
		# (deployed_count was already incremented by spawn signal, so undo it)
		print("[Arena] 👑 King spawned at tile %s" % str(king_tile))
		# Add to king group for easy lookup
		king_node.add_to_group("king")


## Called when battle starts - disable dragging.
func _on_battle_started() -> void:
	_set_drag_enabled(false)

	# Only clear enemy area on first battle start, not between waves
	# (wave manager handles its own cleanup between waves)
	if wave_manager and wave_manager.current_wave_index >= 0:
		# This is a subsequent wave start, wave manager handles spawning
		return

	# Clear any pre-existing enemy units in the enemy area (safety)
	if enemy_area and enemy_area.unit_grid:
		for tile in enemy_area.unit_grid.units.keys():
			var u = enemy_area.unit_grid.units[tile]
			if u:
				enemy_area.unit_grid.remove_unit(tile)
				if is_instance_valid(u):
					u.queue_free()
	
	# If wave manager exists, it handles spawning
	# Otherwise fall back to legacy enemy_wave system
	if wave_manager:
		# Wave manager will start first wave automatically
		return
	
	# LEGACY: Spawn configured enemy wave via UnitSpawner at/around center in batches
	if enemy_wave and unit_spawner and enemy_area and enemy_area.unit_grid:
		var grid_size: Vector2i = enemy_area.unit_grid.size
		var center_tile: Vector2i = Vector2i(grid_size.x >> 1, grid_size.y >> 1)

		# Offsets to place multiple enemies around center (spiral-ish)
		var offsets: Array[Vector2i] = [Vector2i(0,0), Vector2i(-1,0), Vector2i(1,0), Vector2i(0,-1), Vector2i(0,1), Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(1,1)]

		var total: int = int(enemy_wave.size())
		var batch: int = max(1, int(enemy_spawn_batch_size))
		var i: int = 0
		while i < total:
			# Spawn this batch
			var end_idx: int = min(i + batch, total)
			for j in range(i, end_idx):
				var enemy_stats: UnitStats = enemy_wave[j]
				if not enemy_stats:
					continue

				var placed: bool = false
				for off in offsets:
					var try_tile: Vector2i = Vector2i(center_tile.x + off.x, center_tile.y + off.y)
					if try_tile.x < 0 or try_tile.y < 0 or try_tile.x >= grid_size.x or try_tile.y >= grid_size.y:
						continue
					if not enemy_area.unit_grid.is_tile_occupied(try_tile):
						unit_spawner.spawn_unit(enemy_stats, try_tile)
						placed = true
						break
				if not placed:
					unit_spawner.spawn_unit(enemy_stats)

			i += batch
			# Wait between batches if more remain
			if i < total and enemy_spawn_interval > 0:
				await get_tree().create_timer(enemy_spawn_interval).timeout

			# After spawning all batches, enable AI for all units so newly spawned enemies become active
			if battle_manager and battle_manager.has_method("enable_ai_for_all"):
				battle_manager.enable_ai_for_all(true)


## Called when preparation starts - enable dragging.
func _on_preparation_started() -> void:
	_set_drag_enabled(true)
	# Ensure Start button enabled in preparation
	if start_battle_button:
		start_battle_button.disabled = false


## Called when battle ends with a winner.
func _on_battle_ended(winner: UnitStats.Team) -> void:
	if wave_manager and wave_manager.current_wave_index + 1 < wave_manager.waves.size():
		# Between waves — not a final result yet
		print("[Arena] ✅ Wave %d complete! Preparing for next wave..." % wave_manager.current_wave_number)
	elif winner == UnitStats.Team.PLAYER:
		print("[Arena] ✅ VICTORY! All waves cleared!")
		# Victory transition is handled by _on_all_waves_completed
	else:
		print("[Arena] ❌ DEFEAT! All player units eliminated.")
		_transition_to_game_over()
	
	# Re-enable dragging for surviving player units
	_set_drag_enabled(true)


## Called when wave_manager reports all waves cleared.
func _on_all_waves_completed() -> void:
	print("[Arena] 🏆 All waves completed — showing victory screen...")
	_transition_to_victory()


## Transitions to the Victory screen after a short delay.
func _transition_to_victory() -> void:
	await get_tree().create_timer(END_SCREEN_DELAY).timeout
	var victory_scene: PackedScene = load(VICTORY_SCENE)
	var screen: Control = victory_scene.instantiate()
	var total_waves: int = wave_manager.current_wave_number if wave_manager else 0
	# Gather gold/xp from player stats if available
	var gold := 0
	var xp := 0
	if wave_manager and wave_manager.player_stats:
		gold = wave_manager.player_stats.gold
		xp = wave_manager.player_stats.xp
	screen.set("waves_cleared", total_waves)
	screen.set("gold_earned", gold)
	screen.set("xp_earned", xp)
	get_tree().root.add_child(screen)
	get_tree().current_scene = screen
	queue_free()


## Transitions to the Game Over screen after a short delay.
func _transition_to_game_over() -> void:
	await get_tree().create_timer(END_SCREEN_DELAY).timeout
	var go_scene: PackedScene = load(GAME_OVER_SCENE)
	var screen: Control = go_scene.instantiate()
	screen.set("wave_reached", wave_manager.current_wave_number if wave_manager else 0)
	get_tree().root.add_child(screen)
	get_tree().current_scene = screen
	queue_free()


func _on_start_battle_pressed() -> void:
	# If wave manager is waiting between waves, skip prep timer
	if wave_manager and wave_manager.is_waiting_for_next_wave:
		wave_manager.skip_preparation()
		return
	
	# Otherwise, normal start battle during initial preparation
	if battle_manager and battle_manager.current_state == BattleManager.State.PREPARATION:
		battle_manager.force_start_battle()


func _on_battle_state_changed(new_state: int) -> void:
	# Disable the start button during battle, enable during preparation/ended
	if not start_battle_button:
		return
	if new_state == BattleManager.State.PREPARATION:
		start_battle_button.disabled = false
		start_battle_button.text = "Start Battle"
	elif new_state == BattleManager.State.ENDED:
		# After wave ends, button will be re-enabled by wave manager prep phase
		start_battle_button.disabled = false
		if wave_manager and wave_manager.is_waiting_for_next_wave:
			start_battle_button.text = "Next Wave"
		else:
			start_battle_button.text = "Start Battle"
	else:
		start_battle_button.disabled = true
		start_battle_button.text = "Battle..."

	# Toggle unit selection panel interactability
	if unit_selection_panel:
		var can_interact: bool = (new_state == BattleManager.State.PREPARATION or new_state == BattleManager.State.ENDED)
		unit_selection_panel.set_interactable(can_interact)
		if not can_interact:
			unit_selection_panel.visible = false
	if toggle_units_button:
		toggle_units_button.visible = (new_state != BattleManager.State.BATTLE)
		_update_toggle_button_text()


# ── Placement Mode ──

## Toggles the unit selection panel visibility.
func _on_toggle_units_pressed() -> void:
	if not unit_selection_panel:
		return
	unit_selection_panel.visible = not unit_selection_panel.visible
	_update_toggle_button_text()


func _update_toggle_button_text() -> void:
	if toggle_units_button and unit_selection_panel:
		toggle_units_button.text = "Units ▲" if unit_selection_panel.visible else "Units ▼"


## Called when a card is clicked in the panel.
func _on_panel_unit_selected(unit_stats: UnitStats) -> void:
	_placement_stats = unit_stats
	_drag_placing = false
	# Hide panel while placing
	if unit_selection_panel:
		unit_selection_panel.visible = false
		_update_toggle_button_text()
	# Create ghost sprite that follows the cursor
	_create_placement_ghost(unit_stats)


## Called when a card is dragged in the panel — enters drag-placement mode.
func _on_panel_unit_drag_started(unit_stats: UnitStats) -> void:
	_placement_stats = unit_stats
	_drag_placing = true
	# Hide panel while dragging
	if unit_selection_panel:
		unit_selection_panel.visible = false
		_update_toggle_button_text()
	_create_placement_ghost(unit_stats)


## Called when placement is cancelled from the panel (clicking same card again).
func _on_placement_cancelled() -> void:
	_exit_placement_mode()


## Handles unhandled input for placement clicks, cancel, and right-click delete.
func _unhandled_input(event: InputEvent) -> void:
	# ── Mouse scroll zoom ──
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var new_zoom := minf(camera.zoom.x + ZOOM_STEP, ZOOM_MAX)
			camera.zoom = Vector2(new_zoom, new_zoom)
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var new_zoom := maxf(camera.zoom.x - ZOOM_STEP, ZOOM_MIN)
			camera.zoom = Vector2(new_zoom, new_zoom)
			get_viewport().set_input_as_handled()
			return

	# ── Middle-click camera pan ──
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			_camera_panning = true
			_camera_pan_start = event.global_position
		else:
			_camera_panning = false
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion and _camera_panning:
		camera.position -= (event.relative / camera.zoom)
		get_viewport().set_input_as_handled()
		return

	# ── Click outside panel closes it ──
	if not _placement_stats and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if unit_selection_panel and unit_selection_panel.visible:
			unit_selection_panel.visible = false
			_update_toggle_button_text()

	# ── Right-click to delete a placed unit (during prep phase, not in placement mode) ──
	if not _placement_stats and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if battle_manager and battle_manager.current_state != BattleManager.State.BATTLE and game_area:
			var tile := game_area.get_hovered_tile()
			if game_area.is_tile_within_bounds(tile) and game_area.unit_grid.is_tile_occupied(tile):
				_remove_placed_unit(tile)
				get_viewport().set_input_as_handled()
				return

	if not _placement_stats:
		return

	# Right-click or ESC → cancel placement
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_exit_placement_mode()
		if unit_selection_panel:
			unit_selection_panel.cancel_selection()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_exit_placement_mode()
		if unit_selection_panel:
			unit_selection_panel.cancel_selection()
		get_viewport().set_input_as_handled()
		return

	# Left-click → try to place unit on the hovered tile (click mode: on press, drag mode: on release)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var want_place := false
		if _drag_placing and not event.pressed:
			want_place = true  # Drag mode: place on release
		elif not _drag_placing and event.pressed:
			want_place = true  # Click mode: place on press
		if not want_place:
			return
		if not game_area:
			if _drag_placing:
				_exit_placement_mode()
				if unit_selection_panel:
					unit_selection_panel.cancel_selection()
			return
		var tile := game_area.get_hovered_tile()
		if not game_area.is_tile_within_bounds(tile):
			if _drag_placing:
				_exit_placement_mode()
				if unit_selection_panel:
					unit_selection_panel.cancel_selection()
			return
		if game_area.unit_grid.is_tile_occupied(tile):
			print("[Arena] ⚠ Tile %s is occupied!" % str(tile))
			if _drag_placing:
				_exit_placement_mode()
				if unit_selection_panel:
					unit_selection_panel.cancel_selection()
			return

		# Spawn the unit at the chosen tile
		var spawned := unit_spawner.spawn_unit(_placement_stats, tile)
		if spawned:
			print("[Arena] 🟢 Placed %s at tile %s" % [_placement_stats.name, str(tile)])
			if unit_selection_panel:
				unit_selection_panel.on_unit_placed(_placement_stats)
			# Shift held → stay in placement mode for multi-place
			if Input.is_key_pressed(KEY_SHIFT) and _placement_stats:
				# Check if we can still afford / deploy more
				var can_continue := true
				if unit_selection_panel and unit_selection_panel.deployed_count >= unit_selection_panel.max_deployed_units:
					can_continue = false
				if player_stats and _placement_stats and player_stats.gold < _placement_stats.gold_cost:
					can_continue = false
				if not can_continue:
					_exit_placement_mode()
					if unit_selection_panel:
						unit_selection_panel.cancel_selection()
				# else: keep ghost active, stay in placement mode
			else:
				_exit_placement_mode()
				if unit_selection_panel:
					unit_selection_panel.cancel_selection()

		get_viewport().set_input_as_handled()


func _exit_placement_mode() -> void:
	_placement_stats = null
	_drag_placing = false
	# Remove ghost sprite
	if _placement_ghost and is_instance_valid(_placement_ghost):
		_placement_ghost.queue_free()
		_placement_ghost = null
	# Show panel again
	if unit_selection_panel:
		unit_selection_panel.visible = true
		_update_toggle_button_text()


## Removes a placed ally unit from the grid, refunds gold, and frees the node.
func _remove_placed_unit(tile: Vector2i) -> void:
	var unit = game_area.unit_grid.units.get(tile)
	if not unit or not is_instance_valid(unit):
		return
	if not unit.stats:
		return
	# King cannot be removed
	if unit.stats.is_king:
		print("[Arena] ⚠ Cannot remove the King!")
		return

	# Refund gold
	var refund: int = unit.stats.gold_cost
	if player_stats:
		player_stats.gold += refund
		print("[Arena] 🗑 Removed %s from tile %s (refunded %d 💰)" % [unit.stats.name, str(tile), refund])

	# Remove from grid
	game_area.unit_grid.remove_unit(tile)

	# Update panel deployed count
	if unit_selection_panel:
		unit_selection_panel.on_unit_removed()

	# Free the unit
	unit.queue_free()


## Creates a semi-transparent ghost sprite that follows the cursor for placement preview.
func _create_placement_ghost(unit_stats: UnitStats) -> void:
	# Remove old ghost if any
	if _placement_ghost and is_instance_valid(_placement_ghost):
		_placement_ghost.queue_free()

	_placement_ghost = Sprite2D.new()
	_placement_ghost.texture = UnitStats.TEAM_SPRITESHEET.get(unit_stats.team)
	_placement_ghost.region_enabled = true
	_placement_ghost.region_rect = Rect2(
		Vector2(unit_stats.skin_coordinates) * CELL_SIZE,
		CELL_SIZE
	)
	_placement_ghost.modulate = Color(1, 1, 1, 0.6)
	_placement_ghost.z_index = 100
	add_child(_placement_ghost)


var _stats_update_timer: float = 0.0
const STATS_UPDATE_INTERVAL: float = 0.25  ## Update stats display 4x per second instead of every frame

## Updates the unit stats display on a throttled timer.
func _process(delta: float) -> void:
	_stats_update_timer -= delta
	if _stats_update_timer <= 0:
		_stats_update_timer = STATS_UPDATE_INTERVAL
		update_stats_display()

	# Move placement ghost to snap to hovered tile
	if _placement_ghost and is_instance_valid(_placement_ghost) and game_area:
		var tile := game_area.get_hovered_tile()
		if game_area.is_tile_within_bounds(tile):
			_placement_ghost.visible = true
			_placement_ghost.global_position = game_area.get_global_from_tile(tile) - HALF_CELL_SIZE
			# Tint green if free, red if occupied
			if game_area.unit_grid.is_tile_occupied(tile):
				_placement_ghost.modulate = Color(1.0, 0.3, 0.3, 0.5)
			else:
				_placement_ghost.modulate = Color(0.3, 1.0, 0.5, 0.6)
		else:
			_placement_ghost.visible = false


## Updates the unit stats display with current ally units.
func update_stats_display() -> void:
	var ally_units = get_tree().get_nodes_in_group("player_units")
	var current_panels = unit_stats_container.get_children()
	
	# Only rebuild panels if unit count changed
	if current_panels.size() != ally_units.size():
		for child in current_panels:
			child.queue_free()
		
		for unit_node in ally_units:
			var panel = preload("res://scenes/arena/unit_stats_panel.tscn").instantiate()
			unit_stats_container.add_child(panel)
			panel.set_unit(unit_node)
	else:
		# Just update existing panels
		for i in current_panels.size():
			if i < ally_units.size():
				current_panels[i].update_stats()


## Enables or disables dragging for all units.
func _set_drag_enabled(enabled: bool) -> void:
	var all_units := get_tree().get_nodes_in_group("units")
	for unit in all_units:
		if unit.has_node("DragAndDrop"):
			unit.get_node("DragAndDrop").enabled = enabled
