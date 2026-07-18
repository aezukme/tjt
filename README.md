# TJT - Legion TD-Style Wave Defense

A Godot 4.6-based multiplayer wave-defense strategy game inspired by Legion TD 2. Players build armies during preparation phases, defend their King from incoming waves, and outplay opponents through positioning, synergies, and strategic resource management.

## Description

Legion TD-style wave defense with strategic unit placement, faction synergies, and progressive difficulty. Key features:

- **Wave System**: 15 progressive waves with boss waves every 5 rounds, preparation phases between rounds
- **King Defense**: Protect your King from incoming enemy waves — King damage is permanent
- **Faction Synergies**: Warrior (+20% ATK), Mystic (+20% AP), Warden (+15% ATK SPD) bonuses for faction builds
- **Auto-Combat**: AI-driven pathfinding (A*), targeting, and combat — units fight automatically once battle starts
- **Ability System**: Mana-based abilities with auto-cast (Fireball, Mending Bolt, AoE), passive abilities (Warrior's Endurance, Iron Bastion)
- **Unit Management**: Drag-and-drop placement, stat tracking, between-wave position restore and stat reset
- **Battle Flow**: Preparation → Battle → Wave Complete → 30s prep (skippable) → next wave → repeat
- **Economy**: Gold costs, wave rewards, unit selling (full refund), interest system (planned)

## Current Units

### Ally Units (8 + King)
| Unit | Faction | Role | Cost | Ability |
|------|---------|------|------|----------|
| **Bjorn** | Warrior | Tank | 1💰 | Warrior's Endurance (+20% regen) |
| **Knight** | Warrior | Tank | 2💰 | Iron Bastion (+5 armor) |
| **Mage** | Mystic | DPS | 2💰 | Fireball (100 dmg projectile) |
| **Sage** | Mystic | Support | 3💰 | Mending Bolt (heal 60 / dmg 50) |
| **Druid** | Mystic | Specialist | 3💰 | Nature's Wrath (AoE 40 dmg) |
| **Ranger** | Warden | DPS | 3💰 | Power Shot (120 dmg projectile) |
| **Rogue** | Warrior | DPS | 3💰 | Deadly Focus (+25% ATK) |
| **Priest** | Warden | Support | 4💰 | Holy Light (AoE heal 40) |
| **King** 👑 | — | — | — | *(none yet)* |

### Enemy Units (6)
| Unit | HP | ATK | AS | Range | Role |
|------|----|-----|------|-------|------|
| **Orc** | 100 | 10 | 0.7 | 1 | Standard warrior |
| **Necro** | 60 | 10 | 0.8 | 3 | Ranged caster |
| **Goblin** | 50 | 8 | 1.2 | 1 | Fast swarm |
| **Wolf** | 60 | 12 | 1.0 | 1 | Fast flanker |
| **Troll** | 250 | 15 | 0.4 | 1 | Heavy tank |
| **Skeleton Archer** | 70 | 15 | 0.9 | 3 | Ranged DPS |

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
- Viewport: 960×540
- Window: 1920×1080
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

## Development Status

**Current Version**: v0.9 (Pre-Alpha)

**Progress**:
- ✅ Core gameplay loop (90%)
- ✅ Wave system (15 waves)
- ✅ Unit placement (8 units max)
- ✅ Ability system (8 abilities)
- ✅ Combat AI with A* pathfinding
- ✅ King system
- ✅ Faction/synergy system
- ✅ Procedural animations
- 🟡 Economy (40% — income/interest pending)
- 🔴 Multiplayer (10% — foundation only)

See [Game Design Document.md](Game%20Design%20Document.md) for full design vision.
See [TODO.md](TODO.md) for detailed task breakdown.

---

*Built with Godot Engine 4.6 — Last updated: July 2026*