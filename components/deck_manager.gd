extends Node

## Autoload singleton that holds the player's selected deck between scenes.
## The deck is persisted to a config file so the player doesn't need to
## re-select units every session. A default deck is used on first launch.

signal deck_changed

const DECK_SIZE: int = 7
const SAVE_PATH: String = "user://deck.cfg"

## All ally unit resources available for deck building.
const ALLY_UNIT_PATHS: Array[String] = [
	"res://data/units/bjorn_ally.tres",
	"res://data/units/mage_ally.tres",
	"res://data/units/sage_ally.tres",
	"res://data/units/knight_ally.tres",
	"res://data/units/ranger_ally.tres",
	"res://data/units/rogue_ally.tres",
	"res://data/units/priest_ally.tres",
	"res://data/units/druid_ally.tres",
]

## Default deck used on first launch (before player picks their own).
const DEFAULT_DECK_PATHS: Array[String] = [
	"res://data/units/bjorn_ally.tres",
	"res://data/units/mage_ally.tres",
	"res://data/units/sage_ally.tres",
	"res://data/units/knight_ally.tres",
	"res://data/units/ranger_ally.tres",
	"res://data/units/rogue_ally.tres",
	"res://data/units/priest_ally.tres",
]

## The currently selected deck (array of UnitStats resources).
var selected_deck: Array[UnitStats] = []


func _ready() -> void:
	_load_deck()


## Returns all ally unit stats available for deck building.
func get_all_ally_units() -> Array[UnitStats]:
	var units: Array[UnitStats] = []
	for path in ALLY_UNIT_PATHS:
		var stats: UnitStats = load(path)
		if stats:
			units.append(stats)
	return units


## Returns true if the deck has exactly DECK_SIZE units.
func is_deck_complete() -> bool:
	return selected_deck.size() == DECK_SIZE


## Adds a unit to the deck. Returns true if added, false if deck is full or already contains it.
func add_unit(stats: UnitStats) -> bool:
	if selected_deck.size() >= DECK_SIZE:
		return false
	if stats in selected_deck:
		return false
	selected_deck.append(stats)
	deck_changed.emit()
	return true


## Removes a unit from the deck.
func remove_unit(stats: UnitStats) -> void:
	selected_deck.erase(stats)
	deck_changed.emit()


## Clears the deck.
func clear_deck() -> void:
	selected_deck.clear()
	deck_changed.emit()


## Returns true if the deck contains the given unit stats.
func has_unit(stats: UnitStats) -> bool:
	return stats in selected_deck


## Saves the current deck to disk.
func save_deck() -> void:
	var config := ConfigFile.new()
	var paths: Array[String] = []
	for stats in selected_deck:
		paths.append(stats.resource_path)
	config.set_value("deck", "units", paths)
	config.save(SAVE_PATH)


## Loads the deck from disk. Falls back to default deck if no save exists.
func _load_deck() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err == OK and config.has_section_key("deck", "units"):
		var paths: Array = config.get_value("deck", "units", [])
		selected_deck.clear()
		for path in paths:
			var stats: UnitStats = load(path)
			if stats:
				selected_deck.append(stats)
	else:
		# First launch — use default deck
		selected_deck.clear()
		for path in DEFAULT_DECK_PATHS:
			var stats: UnitStats = load(path)
			if stats:
				selected_deck.append(stats)
		save_deck()
