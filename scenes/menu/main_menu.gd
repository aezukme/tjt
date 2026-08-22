class_name MainMenu
extends Control

## Main Menu - entry point of the game.
## "Play" goes directly to Arena using the saved deck.
## "Deck Manager" opens the deck selection screen.

const ARENA_SCENE := "res://scenes/arena/arena.tscn"
const DECK_SELECTION_SCENE := "res://scenes/menu/deck_selection.tscn"

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var deck_manager_button: Button = $CenterContainer/VBoxContainer/DeckManagerButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	deck_manager_button.pressed.connect(_on_deck_manager_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	play_button.grab_focus()


func _on_play_pressed() -> void:
	var loading_script = load("res://scenes/menu/loading_screen.gd")
	loading_script.transition_to(get_tree(), ARENA_SCENE)


func _on_deck_manager_pressed() -> void:
	var loading_script = load("res://scenes/menu/loading_screen.gd")
	loading_script.transition_to(get_tree(), DECK_SELECTION_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
