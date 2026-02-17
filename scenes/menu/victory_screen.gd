class_name VictoryScreen
extends Control

## Shown when all waves are cleared.

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const ARENA_SCENE := "res://scenes/arena/arena.tscn"

@onready var play_again_button: Button = $CenterContainer/VBoxContainer/PlayAgainButton
@onready var menu_button: Button = $CenterContainer/VBoxContainer/MenuButton
@onready var stats_label: Label = $CenterContainer/VBoxContainer/StatsLabel

var waves_cleared: int = 0
var gold_earned: int = 0
var xp_earned: int = 0


func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again)
	menu_button.pressed.connect(_on_menu)
	play_again_button.grab_focus()
	_update_stats()


func setup(p_waves: int, p_gold: int, p_xp: int) -> void:
	waves_cleared = p_waves
	gold_earned = p_gold
	xp_earned = p_xp
	if is_inside_tree():
		_update_stats()


func _update_stats() -> void:
	if stats_label:
		stats_label.text = "Waves: %d  |  Gold: %d  |  XP: %d" % [waves_cleared, gold_earned, xp_earned]


func _on_play_again() -> void:
	get_tree().change_scene_to_file(ARENA_SCENE)


func _on_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
