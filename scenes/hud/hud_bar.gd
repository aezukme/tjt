extends PanelContainer

@export var player_stats: PlayerStats: set = set_player_stats
@export var unit_selection_panel_path: NodePath = NodePath("../UnitSelectionPanel")

@onready var gold_value_label: Label = $MarginContainer/HBoxContainer/GoldBlock/GoldValue
@onready var xp_value_label: Label = $MarginContainer/HBoxContainer/XpBlock/XpValue
@onready var units_value_label: Label = $MarginContainer/HBoxContainer/UnitsBlock/UnitsValue
@onready var wave_value_label: Label = $MarginContainer/HBoxContainer/WaveBlock/WaveValue
@onready var king_hp_value_label: Label = $MarginContainer/HBoxContainer/KingBlock/KingValue
@onready var king_hp_bar: ProgressBar = $MarginContainer/HBoxContainer/KingBlock/KingBar

var wave_manager: WaveManager
var unit_selection_panel: UnitSelectionPanel
var king_unit: Unit = null

var _refresh_timer: float = 0.0
const REFRESH_INTERVAL: float = 0.2


func _ready() -> void:
	wave_manager = get_tree().get_first_node_in_group("wave_manager") as WaveManager
	unit_selection_panel = get_node_or_null(unit_selection_panel_path) as UnitSelectionPanel

	if wave_manager:
		if not wave_manager.wave_started.is_connected(_on_wave_started):
			wave_manager.wave_started.connect(_on_wave_started)
		if not wave_manager.wave_completed.is_connected(_on_wave_completed):
			wave_manager.wave_completed.connect(_on_wave_completed)
		if not wave_manager.all_waves_completed.is_connected(_on_all_waves_completed):
			wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	_setup_tooltips()
	_refresh_all()


func set_player_stats(value: PlayerStats) -> void:
	if player_stats and player_stats.changed.is_connected(_on_player_stats_changed):
		player_stats.changed.disconnect(_on_player_stats_changed)

	player_stats = value

	if player_stats and not player_stats.changed.is_connected(_on_player_stats_changed):
		player_stats.changed.connect(_on_player_stats_changed)

	if is_inside_tree():
		_refresh_resources()


func _process(delta: float) -> void:
	_refresh_timer += delta
	if _refresh_timer < REFRESH_INTERVAL:
		return

	_refresh_timer = 0.0
	_try_bind_king()
	_refresh_king_hp()
	_refresh_units()
	_refresh_wave()


func _on_player_stats_changed() -> void:
	_refresh_resources()


func _on_wave_started(_wave_number: int, _wave_config: WaveConfig) -> void:
	_refresh_wave()


func _on_wave_completed(_wave_number: int) -> void:
	_refresh_wave()


func _on_all_waves_completed() -> void:
	_refresh_wave()


func _on_king_health_changed(_new_health: int) -> void:
	_refresh_king_hp()


func _on_king_tree_exited() -> void:
	king_unit = null
	_refresh_king_hp()


func _refresh_all() -> void:
	_refresh_resources()
	_refresh_units()
	_refresh_wave()
	_try_bind_king()
	_refresh_king_hp()


func _refresh_resources() -> void:
	if player_stats:
		gold_value_label.text = str(player_stats.gold)
		xp_value_label.text = str(player_stats.xp)
	else:
		gold_value_label.text = "--"
		xp_value_label.text = "--"


func _refresh_units() -> void:
	if unit_selection_panel:
		units_value_label.text = "%d/%d" % [unit_selection_panel.deployed_count, unit_selection_panel.max_deployed_units]
	else:
		units_value_label.text = "--"


func _refresh_wave() -> void:
	if not wave_manager:
		wave_value_label.text = "--"
		return

	var total_waves: int = wave_manager.get_total_waves()
	if total_waves <= 0:
		wave_value_label.text = "0/0"
		return

	var current_wave: int = max(wave_manager.current_wave_number, 0)
	var suffix := ""
	if wave_manager.current_wave_number > 0 and wave_manager.is_boss_wave():
		suffix = " Boss"
	elif wave_manager.is_waiting_for_next_wave:
		suffix = " Prep"

	wave_value_label.text = "%d/%d%s" % [min(current_wave, total_waves), total_waves, suffix]


func _try_bind_king() -> void:
	if is_instance_valid(king_unit):
		return

	var kings := get_tree().get_nodes_in_group("king")
	if kings.is_empty():
		return

	var candidate := kings[0]
	if candidate is Unit:
		king_unit = candidate as Unit
		if not king_unit.health_changed.is_connected(_on_king_health_changed):
			king_unit.health_changed.connect(_on_king_health_changed)
		if not king_unit.tree_exited.is_connected(_on_king_tree_exited):
			king_unit.tree_exited.connect(_on_king_tree_exited, CONNECT_ONE_SHOT)


func _refresh_king_hp() -> void:
	if not is_instance_valid(king_unit) or not king_unit.stats:
		king_hp_value_label.text = "--"
		king_hp_bar.max_value = 1
		king_hp_bar.value = 0
		return

	var max_health: int = max(king_unit.stats.max_health, 1)
	var health: int = clampi(int(round(king_unit.current_health)), 0, max_health)
	king_hp_value_label.text = "%d/%d" % [health, max_health]
	king_hp_bar.max_value = max_health
	king_hp_bar.value = health


func _setup_tooltips() -> void:
	gold_value_label.mouse_filter = Control.MOUSE_FILTER_STOP
	xp_value_label.mouse_filter = Control.MOUSE_FILTER_STOP
	units_value_label.mouse_filter = Control.MOUSE_FILTER_STOP
	wave_value_label.mouse_filter = Control.MOUSE_FILTER_STOP
	king_hp_value_label.mouse_filter = Control.MOUSE_FILTER_STOP
	king_hp_bar.mouse_filter = Control.MOUSE_FILTER_STOP

	gold_value_label.tooltip_text = "Available gold for placing units."
	xp_value_label.tooltip_text = "Experience earned from cleared waves."
	units_value_label.tooltip_text = "Deployed player units / maximum allowed units."
	wave_value_label.tooltip_text = "Current wave status and prep state."
	king_hp_value_label.tooltip_text = "King health. If it reaches 0, you lose."
	king_hp_bar.tooltip_text = "King health bar."
