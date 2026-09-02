class_name TimePanel
extends PanelContainer

## Displays elapsed time for the current arena run.

@onready var time_value_label: Label = $MarginContainer/HBox/TimeValue

var _elapsed_seconds: float = 0.0
var _is_running: bool = true


func _ready() -> void:
	_update_display()
	time_value_label.mouse_filter = Control.MOUSE_FILTER_STOP
	time_value_label.tooltip_text = "Total time spent in this run."


func _process(delta: float) -> void:
	if not _is_running:
		return
	_elapsed_seconds += delta
	_update_display()


func stop() -> void:
	_is_running = false


func get_elapsed_seconds() -> float:
	return _elapsed_seconds


static func format_time(seconds: float) -> String:
	var total: int = int(floor(seconds))
	var hours: int = total / 3600
	var minutes: int = (total % 3600) / 60
	var secs: int = total % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, secs]
	return "%02d:%02d" % [minutes, secs]


func _update_display() -> void:
	if time_value_label:
		time_value_label.text = format_time(_elapsed_seconds)
