class_name UnitStats
extends Resource

enum Tier {Tier1, Tier2, Tier3, Tier4, Tier5, Tier6, Tier7}

@export var name: String

@export_category("Data")
@export var gold_cost :=1

@export_category("Visuals")
@export var skin_coordinates: Vector2i

func _to_string() -> String:
	return name
