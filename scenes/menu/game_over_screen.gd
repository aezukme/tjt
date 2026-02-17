class_name GameOverScreen
extends Control

## Shown when all player units are eliminated.

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const ARENA_SCENE := "res://scenes/arena/arena.tscn"

@onready var retry_button: Button = $CenterContainer/VBoxContainer/RetryButton
@onready var menu_button: Button = $CenterContainer/VBoxContainer/MenuButton
@onready var stats_label: Label = $CenterContainer/VBoxContainer/StatsLabel

var wave_reached: int = 0


func _ready() -> void:
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)
	retry_button.grab_focus()
	_update_stats()


func setup(p_wave: int) -> void:
	wave_reached = p_wave
	if is_inside_tree():
		_update_stats()


func _update_stats() -> void:
	if stats_label:
		if wave_reached > 0:
			stats_label.text = "Defeated on Wave %d" % wave_reached
		else:
			stats_label.text = ""


func _on_retry() -> void:
	get_tree().change_scene_to_file(ARENA_SCENE)


func _on_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
