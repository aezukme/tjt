class_name UnitVisuals
extends RefCounted

## Shared visual helpers for Unit and EnemyUnit.
## All methods are static so both unit types can call them without inheritance.

const DamageNumberScene = preload("res://scenes/damage_number/damage_number.tscn")

const HEALTH_FLASH_DURATION: float = 0.05
const SKIN_FLASH_DURATION: float = 0.1


## Returns the health bar color for a given health percentage (0.0–1.0).
static func get_health_bar_color(health_percent: float) -> Color:
	if health_percent >= 0.75:
		return Color(0.0, 0.4, 0.0).lerp(Color(0.0, 0.6, 0.0), (1.0 - health_percent) / 0.25)
	elif health_percent >= 0.50:
		return Color(0.0, 0.6, 0.0).lerp(Color(0.2, 0.9, 0.2), (0.75 - health_percent) / 0.25)
	elif health_percent >= 0.30:
		return Color(0.2, 0.9, 0.2).lerp(Color(1.0, 1.0, 0.0), (0.50 - health_percent) / 0.20)
	elif health_percent >= 0.20:
		return Color(1.0, 1.0, 0.0).lerp(Color(1.0, 0.5, 0.0), (0.30 - health_percent) / 0.10)
	elif health_percent >= 0.10:
		return Color(1.0, 0.5, 0.0).lerp(Color(1.0, 0.2, 0.0), (0.20 - health_percent) / 0.10)
	else:
		return Color(1.0, 0.0, 0.0)


## Creates a StyleBoxFlat with the given color and standard border.
static func create_bar_stylebox(color: Color) -> StyleBoxFlat:
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.border_color = Color(0.13, 0.13, 0.13, 1)
	return style_box


## Applies the health-based color gradient to a ProgressBar.
static func apply_health_bar_color(health_bar: ProgressBar, health_percent: float) -> void:
	if not health_bar:
		return

	var bar_color := get_health_bar_color(health_percent)
	var style_box := create_bar_stylebox(bar_color)

	var theme := health_bar.theme
	if not theme:
		theme = Theme.new()
		health_bar.theme = theme

	theme.set_stylebox("fill", "ProgressBar", style_box)


## Flashes a ProgressBar white briefly. Returns the flash id used.
static func flash_health_bar(health_bar: ProgressBar, tree: SceneTree, flash_id: int) -> int:
	if not health_bar or not is_instance_valid(health_bar):
		return flash_id

	flash_id += 1
	var current_id := flash_id

	var white_style := create_bar_stylebox(Color.WHITE)
	health_bar.add_theme_stylebox_override("fill", white_style)

	# Use a plain Callable with bind — avoid static func callbacks which
	# receive an implicit first argument (the GDScript) causing type errors.
	var _restore := func _restore_health_bar(bar: ProgressBar, eid: int, cid: int) -> void:
		if eid == cid and is_instance_valid(bar):
			bar.remove_theme_stylebox_override("fill")

	tree.create_timer(HEALTH_FLASH_DURATION).timeout.connect(
		_restore.bind(health_bar, current_id, flash_id)
	)

	return flash_id


## Flashes a Sprite2D with a color briefly. Returns the flash id used.
static func flash_skin(skin: Sprite2D, tree: SceneTree, flash_id: int, flash_color: Color = Color.RED) -> int:
	if not skin or not is_instance_valid(skin):
		return flash_id

	flash_id += 1
	var current_id := flash_id

	skin.modulate = flash_color

	var _restore := func _restore_skin(s: Sprite2D, eid: int, cid: int) -> void:
		if eid == cid and is_instance_valid(s):
			s.modulate = Color(1, 1, 1, 1)

	tree.create_timer(SKIN_FLASH_DURATION).timeout.connect(
		_restore.bind(skin, current_id, flash_id)
	)

	return flash_id


## Spawns a floating damage number at the given position.
static func spawn_damage_number(tree: SceneTree, position: Vector2, damage: float, color: Color = Color.WHITE) -> void:
	if not DamageNumberScene:
		return

	var damage_number = DamageNumberScene.instantiate()

	var current_scene = tree.current_scene
	if current_scene:
		current_scene.add_child(damage_number)
	else:
		tree.root.add_child(damage_number)

	damage_number.position = position + Vector2(0, -20)
	damage_number.setup(damage, color)


## Removes a unit from its parent grid and notifies the battle manager.
static func handle_unit_death(unit: Node) -> void:
	var play_area = unit.get_parent()
	if play_area and play_area.has_method("get_tile_from_global") and play_area.unit_grid:
		var tile = play_area.get_tile_from_global(unit.global_position)
		play_area.unit_grid.remove_unit(tile)

	var battle_manager := unit.get_tree().get_first_node_in_group("battle_manager")
	if battle_manager:
		battle_manager.check_win_condition()

	unit.queue_free()


## Sets up team groups for a unit node based on its stats.
static func setup_team_groups(unit: Node, stats: UnitStats) -> void:
	unit.add_to_group("units")
	if stats.team == UnitStats.Team.PLAYER:
		if not unit.is_in_group("player_units"):
			unit.add_to_group("player_units")
	else:
		if not unit.is_in_group("enemy_units"):
			unit.add_to_group("enemy_units")
