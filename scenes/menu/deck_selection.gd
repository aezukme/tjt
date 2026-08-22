class_name DeckSelection
extends Control

## Deck Manager screen — player edits their deck of 7 units.
## Changes are saved automatically. Reached from Main Menu → Deck Manager.

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"

@onready var card_container: GridContainer = $CenterContainer/VBox/CardScroll/CardContainer
@onready var counter_label: Label = $CenterContainer/VBox/CounterLabel
@onready var back_button: Button = $CenterContainer/VBox/ButtonRow/BackButton
@onready var clear_button: Button = $CenterContainer/VBox/ButtonRow/ClearButton
@onready var save_button: Button = $CenterContainer/VBox/ButtonRow/SaveButton

## Map: UnitStats resource path → card node
var _cards: Dictionary = {}


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	save_button.pressed.connect(_on_save_pressed)
	_build_cards()
	# Pre-select current deck (loaded from save in DeckManager)
	for stats in DeckManager.selected_deck:
		_mark_selected(stats, true)
	_update_counter()
	back_button.grab_focus()


func _build_cards() -> void:
	for child in card_container.get_children():
		child.queue_free()
	_cards.clear()

	for stats in DeckManager.get_all_ally_units():
		var card := _create_deck_card(stats)
		card_container.add_child(card)
		_cards[stats.resource_path] = card


func _create_deck_card(stats: UnitStats) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(120, 160)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(vbox)

	# Name
	var name_label := Label.new()
	name_label.text = stats.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)

	# Sprite preview
	var sprite_container := PanelContainer.new()
	sprite_container.custom_minimum_size = Vector2(64, 64)
	sprite_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sprite_preview := TextureRect.new()
	sprite_preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	sprite_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite_preview.custom_minimum_size = Vector2(64, 64)
	sprite_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite_container.add_child(sprite_preview)
	vbox.add_child(sprite_container)

	# Set sprite from spritesheet
	var spritesheet: Texture2D = UnitStats.TEAM_SPRITESHEET.get(stats.team)
	if spritesheet:
		var atlas := AtlasTexture.new()
		atlas.atlas = spritesheet
		atlas.region = Rect2(
			stats.skin_coordinates.x * 32,
			stats.skin_coordinates.y * 32,
			32, 32
		)
		sprite_preview.texture = atlas

	# Stats
	var stats_label := Label.new()
	var range_text := "Melee" if stats.is_melee() else "Range %d" % stats.attack_range
	stats_label.text = "HP:%d ATK:%d\n%s" % [stats.max_health, stats.attack_damage, range_text]
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 11)
	stats_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(stats_label)

	# Cost
	var cost_label := Label.new()
	cost_label.text = "%d gold" % stats.gold_cost
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 11)
	cost_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(cost_label)

	# Faction
	if stats.faction != UnitStats.Faction.NONE:
		var faction_label := Label.new()
		faction_label.text = _faction_name(stats.faction)
		faction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		faction_label.add_theme_font_size_override("font_size", 10)
		faction_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
		faction_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(faction_label)

	# Store stats reference on the card
	card.set_meta("unit_stats", stats)

	# Click handling — left click to toggle, right click to remove
	card.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_on_card_clicked(stats)
				card.accept_event()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_on_card_right_clicked(stats)
				card.accept_event()
	)

	_apply_card_style(card, stats, false)
	return card


func _on_card_clicked(stats: UnitStats) -> void:
	if DeckManager.has_unit(stats):
		DeckManager.remove_unit(stats)
		_mark_selected(stats, false)
	else:
		if not DeckManager.add_unit(stats):
			# Deck is full
			counter_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
			_update_counter()
			return
		_mark_selected(stats, true)
	_update_counter()
	print("[DeckSelection] Toggled %s — deck now has %d units" % [stats.name, DeckManager.selected_deck.size()])


## Right-click always removes the unit from the deck (if selected).
func _on_card_right_clicked(stats: UnitStats) -> void:
	if DeckManager.has_unit(stats):
		DeckManager.remove_unit(stats)
		_mark_selected(stats, false)
		_update_counter()
		print("[DeckSelection] Right-click removed %s — deck now has %d units" % [stats.name, DeckManager.selected_deck.size()])


func _mark_selected(stats: UnitStats, selected: bool) -> void:
	var card = _cards.get(stats.resource_path)
	if card:
		_apply_card_style(card, stats, selected)


func _apply_card_style(card: PanelContainer, stats: UnitStats, selected: bool) -> void:
	var rarity_color: Color = UnitStats.RARITY_COLORS.get(stats.rarity, Color.WHITE)
	var style := StyleBoxFlat.new()
	if selected:
		style.bg_color = Color(0.2, 0.3, 0.2, 0.95)
		style.border_color = Color(0.4, 1.0, 0.4)
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		card.modulate = Color.WHITE
	else:
		style.bg_color = Color(0.15, 0.18, 0.22, 0.95)
		style.border_color = rarity_color
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	card.add_theme_stylebox_override("panel", style)


func _update_counter() -> void:
	var count := DeckManager.selected_deck.size()
	counter_label.text = "Deck: %d / %d" % [count, DeckManager.DECK_SIZE]
	if count == DeckManager.DECK_SIZE:
		counter_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	else:
		counter_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))


func _on_back_pressed() -> void:
	# Deck is saved explicitly via Save button
	var loading_script = load("res://scenes/menu/loading_screen.gd")
	loading_script.transition_to(get_tree(), MENU_SCENE)


func _on_save_pressed() -> void:
	DeckManager.save_deck()
	print("[DeckSelection] Deck saved manually")
	# Brief visual feedback
	save_button.text = "Saved!"
	await get_tree().create_timer(1.0).timeout
	save_button.text = "Save"


func _on_clear_pressed() -> void:
	DeckManager.clear_deck()
	for stats in _cards.keys():
		var card = _cards[stats]
		var unit_stats: UnitStats = card.get_meta("unit_stats")
		_apply_card_style(card, unit_stats, false)
	_update_counter()
	print("[DeckSelection] Deck cleared")


func _faction_name(faction: UnitStats.Faction) -> String:
	match faction:
		UnitStats.Faction.WARRIOR: return "Warrior"
		UnitStats.Faction.MYSTIC: return "Mystic"
		UnitStats.Faction.WARDEN: return "Warden"
	return ""
