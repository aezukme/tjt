class_name MainMenu
extends Control

## Main Menu - entry point of the game.
## "Play" transitions to the arena scene.

const ARENA_SCENE := "res://scenes/arena/arena.tscn"

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	# Grab focus so keyboard/gamepad works
	play_button.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(ARENA_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
