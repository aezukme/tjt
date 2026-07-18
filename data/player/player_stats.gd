class_name PlayerStats
extends Resource

@export_range(0, 9999) var gold: int: set = _set_gold
@export_range(0, 99) var xp: int: set = _set_xp
@export_range(1, 10) var level: int: set = _set_level

var income: int = 0
var base_income: int = 0
var interest_income: int = 0

signal income_changed(new_income: int)

func _set_xp(value: int) -> void:
	xp = value
	emit_changed()

func _set_level(value: int) -> void:
	level = value
	emit_changed()

func _set_gold(value: int) -> void:
	gold = value
	emit_changed()

func calculate_income() -> void:
	var old_income: int = income
	base_income = 10  # Base income per wave
	interest_income = min(gold / 10, 10)  # 1 income per 10 gold, capped at 10
	income = base_income + interest_income
	if income != old_income:
		income_changed.emit(income)

func get_income_breakdown() -> Dictionary:
	return {
		"total": income,
		"base": base_income,
		"interest": interest_income
	}
