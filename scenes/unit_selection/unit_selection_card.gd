class_name UnitSelectionCard
extends PanelContainer

## A clickable card that shows a unit's name, sprite preview, and key stats.
## Clicking selects this unit type for placement on the arena.

signal card_clicked(unit_stats: UnitStats)

@onready var name_label: Label = $VBox/NameLabel
@onready var sprite_preview: TextureRect = $VBox/SpriteContainer/SpritePreview
@onready var stats_label: Label = $VBox/StatsLabel
@onready var cost_label: Label = $VBox/CostLabel

var unit_stats: UnitStats
var is_selected: bool = false
var can_afford: bool = true


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func setup(stats: UnitStats) -> void:
	unit_stats = stats
	_update_display()


func _update_display() -> void:
	if not unit_stats or not is_inside_tree():
		return

	name_label.text = unit_stats.name

	# Set sprite preview from spritesheet using AtlasTexture
	if sprite_preview:
		var spritesheet: Texture2D = UnitStats.TEAM_SPRITESHEET.get(unit_stats.team)
		if spritesheet:
			var atlas := AtlasTexture.new()
			atlas.atlas = spritesheet
			atlas.region = Rect2(
				unit_stats.skin_coordinates.x * 32,
				unit_stats.skin_coordinates.y * 32,
				32, 32
			)
			sprite_preview.texture = atlas

	# Stats summary
	var range_text := "Melee" if unit_stats.is_melee() else "Range %d" % unit_stats.attack_range
	stats_label.text = "HP:%d ATK:%d\n%s" % [unit_stats.max_health, unit_stats.attack_damage, range_text]

	# Gold cost
	if cost_label:
		cost_label.text = "%d 💰" % unit_stats.gold_cost

	_update_style()


func set_can_afford(affordable: bool) -> void:
	can_afford = affordable
	_update_style()


func _update_style() -> void:
	if not unit_stats:
		return
	var rarity_color: Color = UnitStats.RARITY_COLORS.get(unit_stats.rarity, Color.WHITE)
	var style := StyleBoxFlat.new()
	if not can_afford:
		style.bg_color = Color(0.12, 0.12, 0.12, 0.95)
		style.border_color = Color(0.4, 0.4, 0.4)
	elif is_selected:
		style.bg_color = Color(0.2, 0.25, 0.35, 0.95)
		style.border_color = Color(1.0, 1.0, 0.4)
	else:
		style.bg_color = Color(0.15, 0.18, 0.22, 0.95)
		style.border_color = rarity_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	add_theme_stylebox_override("panel", style)
	# Dim the whole card if unaffordable
	if not is_selected:
		modulate = Color.WHITE if can_afford else Color(0.5, 0.5, 0.5)


func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_style()
	modulate = Color.WHITE


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not can_afford:
			return
		card_clicked.emit(unit_stats)
		accept_event()


func _on_mouse_entered() -> void:
	if not is_selected:
		modulate = Color(1.15, 1.15, 1.15)


func _on_mouse_exited() -> void:
	if not is_selected:
		modulate = Color.WHITE
