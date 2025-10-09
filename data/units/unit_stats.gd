class_name UnitStats
extends Resource

@export var name: String

@export_category("Data")
@export var gold_cost := 1
@export_range(1, 7) var tier := 1 : set = _set_tier

@export_category("Visuals")
@export var skin_coordinates: Vector2i

## Returns the number of units combined based on tier (3^(tier-1)).
func get_combined_unit_count() -> int:
	return 3 ** (tier - 1)

## Returns the total gold value of this unit (cost × combined count).
func get_gold_value() -> int:
	return gold_cost * get_combined_unit_count()

## Sets the tier value and emits a changed signal for resource updates.
func _set_tier(value: int) -> void:
	tier = value
	emit_changed()

## Returns a string representation of the unit stats (the unit's name).
func _to_string() -> String:
	return name
