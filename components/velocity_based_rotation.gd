class_name VelocityBasedRotation
extends Node

@export var enabled: bool = true : set = _set_enabled
@export var target: Node2D
@export var drag_and_drop: DragAndDrop
@export_range(0.25, 1.5) var lerp_seconds := 0.4
@export var rotation_multiplier := 120
@export_range(0.1, 10.0) var x_velocity_threshold := 3.0

var last_position: Vector2
var velocity: Vector2
var target_angle: float
var just_dropped := false


## Called when the node enters the scene tree. Initializes last position and connects drag signals.
func _ready() -> void:
	if target:
		last_position = target.global_position
	
	# Auto-assign drag_and_drop if not set
	if not drag_and_drop:
		drag_and_drop = get_node_or_null("DragAndDrop")
		if not drag_and_drop and get_parent():
			drag_and_drop = get_parent().get_node_or_null("DragAndDrop")
		if drag_and_drop:
			drag_and_drop.dropped.connect(_on_dropped)
			drag_and_drop.drag_canceled.connect(_on_drag_canceled)


## Handles smooth rotation of the target node based on drag velocity and state.
func _process(delta: float) -> void:
	if not enabled or not target:
		return
	
	# If just dropped, skip processing to maintain instant reset
	if just_dropped:
		just_dropped = false
		return
	
	# Calculate velocity per second
	velocity = (target.global_position - last_position) / delta
	last_position = target.global_position
	
	# Determine if we should rotate
	var is_dragging = drag_and_drop != null and drag_and_drop.dragging
	var is_moving = abs(velocity.x) > x_velocity_threshold
	
	# If no drag_and_drop component, always use smooth rotation
	if drag_and_drop == null:
		if is_moving:
			var direction = sign(velocity.x)
			target_angle = deg_to_rad(direction * rotation_multiplier)
		else:
			target_angle = 0.0
		
		var lerp_weight = 1.0 - exp(-delta / max(lerp_seconds, 0.001))
		target.rotation = lerp_angle(target.rotation, target_angle, lerp_weight)
		return
	
	# With drag_and_drop component - check if dropped first
	if not is_dragging:
		target.rotation = 0.0
		return
	
	# Now we know we're dragging
	if is_moving:
		# Smooth rotation while dragging and moving
		var direction = sign(velocity.x)
		target_angle = deg_to_rad(direction * rotation_multiplier)
		var lerp_weight = 1.0 - exp(-delta / max(lerp_seconds, 0.001))
		target.rotation = lerp_angle(target.rotation, target_angle, lerp_weight)
	else:
		# Smooth rotation back to 0 while dragging but not moving
		target_angle = 0.0
		var lerp_weight = 1.0 - exp(-delta / max(lerp_seconds, 0.001))
		target.rotation = lerp_angle(target.rotation, target_angle, lerp_weight)


## Enables or disables the rotation effect, resetting rotation if disabled.
func _set_enabled(value: bool) -> void:
	enabled = value
	
	if target and enabled == false:
		target.rotation = 0.0


## Resets rotation and state when the drag is dropped.
func _on_dropped(_starting_position: Vector2) -> void:
	if target:
		target.rotation = 0.0
		just_dropped = true


## Resets rotation and state when the drag is canceled.
func _on_drag_canceled(_starting_position: Vector2) -> void:
	if target:
		target.rotation = 0.0
		just_dropped = true
