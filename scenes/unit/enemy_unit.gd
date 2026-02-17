@tool
class_name EnemyUnit
extends Area2D

const CELL_SIZE := Vector2(32, 32)

@export var stats: UnitStats : set = set_stats

@onready var skin: Sprite2D = $Visuals/Skin
@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $ManaBar
@onready var velocity_based_rotation: VelocityBasedRotation = $VelocityBasedRotation

var _health_flash_id: int = 0
var _skin_flash_id: int = 0

## Threat bookkeeping — lets AI avoid overkill / overheal
var incoming_damage: float = 0.0
var incoming_healing: float = 0.0

func get_effective_health() -> float:
	if stats:
		return maxf(stats.health - incoming_damage, 0.0)
	return 0.0

func get_effective_missing_health() -> float:
	if stats:
		var effective_hp: float = minf(stats.health + incoming_healing, stats.max_health)
		return maxf(stats.max_health - effective_hp, 0.0)
	return 0.0

## Called when the node enters the scene tree.
func _ready() -> void:
	if not Engine.is_editor_hint():
		# Connect stats signals
		if stats:
			_connect_stats_signals()


## Connects to unit stats signals.
func _connect_stats_signals() -> void:
	if not stats:
		return

	# Prevent duplicate connections
	if stats.health_reached_zero.is_connected(_on_health_reached_zero):
		return

	stats.health_reached_zero.connect(_on_health_reached_zero)

	# Connect health_changed signal
	stats.health_changed.connect(func(_new_health): _update_health_bar())

	# Add to team groups via shared helper
	UnitVisuals.setup_team_groups(self, stats)

	# Initialize health and mana
	stats.reset_health()
	stats.reset_mana()
	_update_health_bar()
	_update_mana_bar()


var _last_health_value: float = -1.0

## Updates health bar display.
func _update_health_bar() -> void:
	if not stats or not health_bar:
		return

	health_bar.max_value = stats.get_max_health()
	health_bar.value = stats.health

	# Update health bar color based on health percentage
	_update_health_bar_color()

	# Flash effect only when actually taking damage (health decreased)
	if _last_health_value > 0 and stats.health < _last_health_value:
		_flash_health_bar()
	_last_health_value = stats.health


## Update health bar color gradient based on health percentage.
func _update_health_bar_color() -> void:
	if not stats or not health_bar:
		return
	var health_percent: float = float(stats.health) / float(stats.get_max_health())
	UnitVisuals.apply_health_bar_color(health_bar, health_percent)


## Flash health bar white when taking damage.
func _flash_health_bar() -> void:
	_health_flash_id = UnitVisuals.flash_health_bar(health_bar, get_tree(), _health_flash_id)


## Flash the unit's skin for visual feedback.
func flash_skin(flash_color: Color = Color.RED) -> void:
	_skin_flash_id = UnitVisuals.flash_skin(skin, get_tree(), _skin_flash_id, flash_color)


## Updates mana bar display.
func _update_mana_bar() -> void:
	if not stats or not mana_bar:
		return

	mana_bar.max_value = stats.max_mana
	mana_bar.value = stats.mana


## Called when unit's health reaches zero.
func _on_health_reached_zero() -> void:
	print("%s died!" % stats.name)
	UnitVisuals.handle_unit_death(self)


## Apply damage to this enemy unit (uniform interface for AI/abilities).
func apply_damage(damage: int) -> void:
	if stats:
		stats.health = max(stats.health - damage, 0)
	# Reduce incoming_damage since this damage has now landed
	incoming_damage = maxf(incoming_damage - damage, 0.0)


## Sets the unit's stats and updates the skin position accordingly.
func set_stats(value: UnitStats) -> void:
	stats = value

	if value == null:
		return

	if not is_node_ready():
		await ready

	# Set the correct spritesheet based on team
	skin.texture = value.TEAM_SPRITESHEET[value.team]
	skin.region_rect.position = Vector2(stats.skin_coordinates) * CELL_SIZE

	# Connect stats signals if not in editor
	if not Engine.is_editor_hint():
		_connect_stats_signals()