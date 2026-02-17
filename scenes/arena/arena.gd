class_name Arena
extends Node2D

const CELL_SIZE := Vector2(32, 32)
const HALF_CELL_SIZE := Vector2(16, 16)
const QUARTER_CELL_SIZE := Vector2(8, 8)

const VICTORY_SCENE := "res://scenes/menu/victory_screen.tscn"
const GAME_OVER_SCENE := "res://scenes/menu/game_over_screen.tscn"
const END_SCREEN_DELAY := 1.5  ## Seconds before transitioning to end screen

@onready var unit_mover: UnitMover = $UnitMover
@onready var unit_spawner: UnitSpawner = $UnitSpawner
@onready var sell_portal: SellPortal = $SellPortal
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

## Called when the node enters the scene tree. Connects unit spawner to unit mover.
func _ready() -> void:
	unit_spawner.unit_spawned.connect(unit_mover.setup_unit)
	unit_spawner.unit_spawned.connect(sell_portal.setup_unit)
	
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
		unit_selection_panel.placement_cancelled.connect(_on_placement_cancelled)
		# Count pre-placed player units
		var preplaced := get_tree().get_nodes_in_group("player_units")
		unit_selection_panel.deployed_count = preplaced.size()
		# Start with panel hidden
		unit_selection_panel.visible = false
		# Wire player stats for gold tracking
		var _sell_portal = get_node_or_null("SellPortal")
		if _sell_portal and "player_stats" in _sell_portal and _sell_portal.player_stats:
			unit_selection_panel.set_player_stats(_sell_portal.player_stats)

	# Toggle button for unit panel
	if toggle_units_button:
		toggle_units_button.pressed.connect(_on_toggle_units_pressed)


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
	# Hide panel while placing
	if unit_selection_panel:
		unit_selection_panel.visible = false
		_update_toggle_button_text()
	# Create ghost sprite that follows the cursor
	_create_placement_ghost(unit_stats)


## Called when placement is cancelled from the panel (clicking same card again).
func _on_placement_cancelled() -> void:
	_exit_placement_mode()


## Handles unhandled input for placement clicks and cancel.
func _unhandled_input(event: InputEvent) -> void:
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

	# Left-click → try to place unit on the hovered tile
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not game_area:
			return
		var tile := game_area.get_hovered_tile()
		if not game_area.is_tile_within_bounds(tile):
			return
		if game_area.unit_grid.is_tile_occupied(tile):
			print("[Arena] ⚠ Tile %s is occupied!" % str(tile))
			return

		# Spawn the unit at the chosen tile
		var spawned := unit_spawner.spawn_unit(_placement_stats, tile)
		if spawned:
			print("[Arena] 🟢 Placed %s at tile %s" % [_placement_stats.name, str(tile)])
			if unit_selection_panel:
				unit_selection_panel.on_unit_placed(_placement_stats)
			# Exit placement mode (show panel for next pick)
			_exit_placement_mode()
			if unit_selection_panel:
				unit_selection_panel.cancel_selection()

		get_viewport().set_input_as_handled()


func _exit_placement_mode() -> void:
	_placement_stats = null
	# Remove ghost sprite
	if _placement_ghost and is_instance_valid(_placement_ghost):
		_placement_ghost.queue_free()
		_placement_ghost = null
	# Show panel again
	if unit_selection_panel:
		unit_selection_panel.visible = true
		_update_toggle_button_text()


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
