# TJT - Auto-Battler (TFT-style)

A Godot 4.6-based auto-battler game inspired by Teamfight Tactics. Players place ally units on a grid arena and watch them battle waves of enemies in automated combat.

## Description

Wave-based auto-battler with strategic unit placement, ability systems, and progressive difficulty. Key features:

- **Wave System**: 4+ progressive waves with difficulty scaling (5% per wave), preparation phases between rounds, and boss waves
- **Auto-Combat**: AI-driven pathfinding (A*), targeting, and combat — units fight automatically once battle starts
- **Ability System**: Mana-based abilities with auto-cast (Fireball, Mending Bolt, AOE), passive abilities (Warrior's Endurance), and projectile visuals
- **Unit Management**: Drag-and-drop placement, stat tracking (HP, mana, attack, armor, magic resist, attack speed), between-wave position restore and stat reset
- **Battle Flow**: Preparation → Battle → Wave Complete → 30s prep (skippable) → next wave → repeat
- **Economy**: Gold rewards per wave, experience system (planned)

## Current Units

### Allies
| Unit | Role | HP | ATK | Range | Ability |
|------|------|-----|-----|-------|---------|
| **Bjorn** | Warrior/Tank | 500 | 50 | Melee | Warrior's Endurance (+20% HP regen) |
| **Mage** | Ranged DPS | 400 | 40 | 3 tiles | Fireball (100 dmg, projectile) |
| **Sage** | Healer/Support | 350 | 25 | 3 tiles | Mending Bolt (heal 60 or damage 50) |

### Enemies
| Unit | Role | HP | ATK | Range |
|------|------|-----|-----|-------|
| **Orc** | Melee bruiser | 100 | 10 | Melee |
| **Necro** | Ranged caster | 60 | 10 | 3 tiles |

## Project Structure

```
scenes/
  arena/        # Main arena scene, UI panels, battle orchestration
  unit/         # Unit and EnemyUnit scenes (Area2D + visuals + combat)
  projectile/   # Ability projectile scene
  damage_number/ # Floating damage text
  wave_display/ # Wave progress UI (wave #, enemies, timer, difficulty)
  sell_portal/  # Unit selling area
  shop/         # Shop interface (planned)

components/
  battle_manager.gd   # State machine: PREPARATION → BATTLE → ENDED
  wave_manager.gd     # Wave progression, enemy spawning, between-wave flow
  unit_ai.gd          # A* pathfinding, targeting, attack logic
  unit_grid.gd        # Grid-based tile occupation tracking
  unit_mover.gd       # Drag-and-drop between play areas
  unit_spawner.gd     # Runtime unit instantiation
  unit_visuals.gd     # Shared visual helpers (health bar, flashes, damage numbers)
  play_area.gd        # TileMap-based play zone
  drag_and_drop.gd    # Mouse drag input handling
  tile_highlighter.gd # Tile highlight feedback
  outline_highlighter.gd # Unit outline shader control
  velocity_based_rotation.gd # Rotation during drag movement

data/
  units/        # UnitStats resources (.tres) — HP, mana, attack, abilities
  abilities/    # Ability resources — Fireball, Mending Bolt, Heal, AOE
  waves/        # WaveConfig resources — enemy groups, rewards, difficulty
  player/       # Player stats (gold, XP)

asset/          # Sprites (32rogues), tilesets, fonts, music, SFX, shaders
addons/         # Editor plugins (CodeBot, SpriteFrames Generator)
```

## Core Systems

### Battle Flow
1. **Preparation Phase** — Place/reposition units on the grid via drag-and-drop
2. **Battle Phase** — AI takes over: pathfinding, targeting, attacks, abilities
3. **Wave Complete** — Enemies cleared, gold/XP rewards distributed
4. **Between-Wave Prep** — 30s timer (skippable), units return to saved positions, stats fully reset
5. **Repeat** until all waves cleared or all allies die

### AI System
- A* pathfinding on grid with obstacle avoidance
- Aggro range-based targeting (closest enemy within range)
- Automatic attack cooldowns based on attack_speed stat
- Ability auto-cast when mana reaches max
- Debug logging with `DEBUG_AI = true` flag

### Damage Calculation
- Physical: `damage * (100 / (100 + armor))`
- Magical: `damage * (100 / (100 + magic_resist))`
- Healing: Direct HP restoration (Sage's Mending Bolt)

### Regeneration
- Float-based HP/mana regen during BATTLE phase only
- Delta-time independent for smooth frame-rate-safe regeneration

### Unit Stats
Each unit has the following stats (configured in .tres files):
- `max_health` & `health_regen`: Hit points and regeneration rate
- `max_mana`, `starting_mana`, & `mana_regen`: Resource for abilities
- `attack_damage`, `ability_power`: Damage scaling
- `attack_speed`: Attacks per second
- `armor`, `magic_resist`: Damage reduction
- `attack_range`, `aggro_range`: Combat ranges

## Requirements

- Godot Engine 4.6+ (GL Compatibility renderer)
- Viewport: 640×360, window: 1300×750
- Integer scaling, pixel-perfect 2D snapping

## How to Run

1. Clone the repository
2. Open in Godot Engine 4.6+
3. Import via `project.godot`
4. Run — main scene is the Arena

## Controls

- **Left click** — Select / drag units
- **Right click / Escape** — Cancel drag
- **Start Battle button** — Begin wave / skip preparation timer

## License

See LICENSE file for details.

---
*Built with Godot Engine 4.6.1 — Last updated: February 2026*