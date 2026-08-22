class_name VFXSpawner
extends Node

## Spawns temporary animated VFX sprites at world positions.
## Used by abilities, attacks, and death effects.
## Each VFX type is defined as a dictionary with texture, frame layout, and playback settings.

## Emitted when a VFX is spawned (for debugging/audio hooks)
signal vfx_spawned(vfx_type: String, position: Vector2)

const CELL_SIZE: int = 32

## VFX definitions — keyed by name.
## Each entry: { texture, cols, rows, frames, fps, scale, color, loop }
var _vfx_defs: Dictionary = {}

## Parent node to spawn VFX under (defaults to get_tree().current_scene)
var _container: Node = null


func _ready() -> void:
	# Add to group so other components can find us
	add_to_group("vfx_spawner")
	# Try to find the arena/game area as container
	_container = get_parent()
	_setup_vfx_defs()


## Sets up all VFX definitions from the spritesheets in asset/sprites/vfx/.
func _setup_vfx_defs() -> void:
	# ── Explosions ──
	_vfx_defs["explosion"] = {
		"texture": load("res://asset/sprites/vfx/explosions/explosion_1a.png"),
		"cols": 8, "rows": 1, "frames": 7, "fps": 12,
		"scale": 1.5, "color": Color.WHITE, "loop": false,
	}
	_vfx_defs["explosion_fire"] = {
		"texture": load("res://asset/sprites/vfx/explosions/explosion_red.png"),
		"cols": 20, "rows": 16, "frames": 20, "fps": 20,
		"scale": 1.5, "color": Color.WHITE, "loop": false,
	}
	_vfx_defs["explosion_magic"] = {
		"texture": load("res://asset/sprites/vfx/explosions/explosion_blue.png"),
		"cols": 20, "rows": 16, "frames": 20, "fps": 20,
		"scale": 1.5, "color": Color.WHITE, "loop": false,
	}
	_vfx_defs["explosion_heal"] = {
		"texture": load("res://asset/sprites/vfx/explosions/explosion_green.png"),
		"cols": 20, "rows": 16, "frames": 20, "fps": 15,
		"scale": 1.5, "color": Color.WHITE, "loop": false,
	}
	_vfx_defs["explosion_dark"] = {
		"texture": load("res://asset/sprites/vfx/explosions/explosion_purple.png"),
		"cols": 20, "rows": 16, "frames": 20, "fps": 20,
		"scale": 1.5, "color": Color.WHITE, "loop": false,
	}

	# ── Hit effects ──
	_vfx_defs["hit_physical"] = {
		"texture": load("res://asset/sprites/vfx/hit_effects/hit_main.png"),
		"cols": 4, "rows": 28, "frames": 8, "fps": 15,
		"scale": 1.0, "color": Color.WHITE, "loop": false,
	}

	# ── Misc ──
	_vfx_defs["thunder"] = {
		"texture": load("res://asset/sprites/vfx/misc/thunder.png"),
		"cols": 16, "rows": 8, "frames": 16, "fps": 20,
		"scale": 1.5, "color": Color.WHITE, "loop": false,
	}
	_vfx_defs["death_effect"] = {
		"texture": load("res://asset/sprites/vfx/explosions/explosion_1a.png"),
		"cols": 8, "rows": 1, "frames": 7, "fps": 10,
		"scale": 1.0, "color": Color(1.0, 0.8, 0.4, 0.8), "loop": false,
	}


## Spawns a VFX at the given world position.
## vfx_type: key in _vfx_defs (e.g. "explosion_fire", "hit_physical")
## world_pos: global position in 2D space
## Returns the spawned AnimatedSprite2D node (auto-freed when animation finishes).
func spawn_vfx(vfx_type: String, world_pos: Vector2) -> AnimatedSprite2D:
	var def: Dictionary = _vfx_defs.get(vfx_type, {})
	if def.is_empty():
		push_warning("[VFX] Unknown VFX type: %s" % vfx_type)
		return null

	var texture: Texture2D = def["texture"]
	if not texture:
		push_warning("[VFX] Missing texture for: %s" % vfx_type)
		return null

	# Build SpriteFrames from the spritesheet
	var frames := SpriteFrames.new()
	var anim_name := "default"
	# SpriteFrames.new() already has a "default" animation — remove it first
	if frames.has_animation(anim_name):
		frames.remove_animation(anim_name)
	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, def.get("loop", false))
	frames.set_animation_speed(anim_name, def.get("fps", 15))

	var cols: int = def["cols"]
	var rows: int = def["rows"]
	var total_frames: int = def["frames"]
	var frame_size: Vector2i = Vector2i(CELL_SIZE, CELL_SIZE)

	var frame_idx := 0
	for r in range(rows):
		for c in range(cols):
			if frame_idx >= total_frames:
				break
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(
				c * CELL_SIZE, r * CELL_SIZE,
				CELL_SIZE, CELL_SIZE
			)
			frames.add_frame(anim_name, atlas, 1.0 / def.get("fps", 15))
			frame_idx += 1
		if frame_idx >= total_frames:
			break

	# Create the animated sprite
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.animation = anim_name
	sprite.global_position = world_pos
	sprite.scale = Vector2(def.get("scale", 1.0), def.get("scale", 1.0))
	sprite.modulate = def.get("color", Color.WHITE)
	sprite.z_index = 50  # Above units
	sprite.play(anim_name)

	# Add to container
	if _container:
		_container.add_child(sprite)
	else:
		get_tree().current_scene.add_child(sprite)

	# Auto-free when animation finishes
	if not def.get("loop", false):
		sprite.animation_finished.connect(func(): sprite.queue_free())

	vfx_spawned.emit(vfx_type, world_pos)
	return sprite


## Spawns a VFX at a unit's position (centered on the unit).
func spawn_vfx_on_unit(vfx_type: String, unit: Node2D) -> AnimatedSprite2D:
	if not is_instance_valid(unit):
		return null
	return spawn_vfx(vfx_type, unit.global_position)


## Returns true if the given VFX type exists.
func has_vfx(vfx_type: String) -> bool:
	return _vfx_defs.has(vfx_type)
