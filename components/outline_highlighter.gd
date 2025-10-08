class_name OutlineHighlighter
extends Node

@export var visuals: CanvasGroup
@export var outline_color: Color
@export_range(1, 10) var outline_thickness: int


## Sets the outline color shader parameter on ready.
func _ready() -> void:
	visuals.material.set_shader_parameter("line_color", outline_color)


## Clears the outline highlight by setting thickness to 0.
func clear_highlight() -> void:
	visuals.material.set_shader_parameter("line_thickness", 0)


## Applies the outline highlight by setting thickness to the configured value.
func highlight() -> void:
	visuals.material.set_shader_parameter("line_thickness", outline_thickness)
