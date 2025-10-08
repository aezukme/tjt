
# Spawns units into the first available play area (enemy or game area).
class_name UnitSpawner
extends Node


# Emitted when a unit is spawned and added to the scene.
signal unit_spawned(unit: Unit)


# Preloads the unit scene for instancing new units.
const UNIT = preload("res://scenes/unit/unit.tscn")


# References to the enemy and game play areas where units can be spawned.
@export var enemy_area: PlayArea
@export var game_area: PlayArea


# Returns the first play area (enemy or game) that has available space for a unit.
func _get_first_available_area() -> PlayArea:
	if not enemy_area.unit_grid.is_grid_full():
		return enemy_area
	elif not game_area.unit_grid.is_grid_full():
		return game_area
    
	return null



# Spawns a new unit with the given stats in the first available play area.
# Emits the unit_spawned signal after adding the unit.
func spawn_unit(unit: UnitStats) -> void:
	var area := _get_first_available_area()
	assert(area, "No available space to add unit to!")
    
	var new_unit := UNIT.instantiate()
	var tile := area.unit_grid.get_first_available_tile()
	area.unit_grid.add_child(new_unit)
	area.unit_grid.add_unit(tile, new_unit)
	new_unit.global_position = area.get_global_from_tile(tile) - Arena.HALF_CELL_SIZE
	new_unit.stats = unit
	unit_spawned.emit(new_unit)
