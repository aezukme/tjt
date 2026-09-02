# TJT — Legion TD meets OCG

A Godot 4.7-based hybrid strategy game that fuses **Legion TD 2** wave-defense
gameplay with **Original Card Game (OCG)** deck-building and **permadeath**.

Players build a predefined **unit deck** before the match, choose a **King**
(with future aura effects), place static defenders on their lane, and survive
progressive waves of enemies. Dead units stay dead — every loss is permanent,
so positioning and deck composition matter more than economy spam.

## Design Identity

TJT is **not**:

- TFT-style auto-battler (no board swapping, no items, no shop reroll)
- Vampire Survivors / RTS / MOBA

TJT **is**:

- Legion TD 2 wave defense (static defenders, progressive waves, King defense)
- OCG deck-building (predefined unit set chosen before the match)
- Permadeath (units that die in a match stay dead — like card games)
- King auras (planned — King type grants passive effects to defenders)
- Multiplayer-first (future 1v1 / 2v2 / 3v3 / 4v4 / coop)

### Legion TD 2 influences

- Static defenders placed on a lane during build phase
- Progressive, learnable wave patterns (15 waves, boss every 5th)
- Unit tiers (currently up to 7) and per-unit upgrade paths (planned)
- King as the player's life — leak damage is permanent
- Map / lane design (expanding with multiplayer in mind)
- Sending units to opponents in PvP (planned — sent from your personal
  predefined deck, **no separate mercenary barracks**)

### Where Legion TD influence ends

- **Deck-building**: each player pre-selects a unit set before the match,
  similar to an OCG deck. You fight with what you brought.
- **King selection**: players choose a King type before the match. Future
  Kings will grant aura effects to defenders.
- **Permadeath**: a unit that dies during a match is gone for the rest of
  the match. There is no respawn, no wave-reset revive. This mirrors card
  games where played cards are consumed.

## Description

Wave-based strategy defense with deck-building, unit placement, ability
systems, and progressive difficulty. Key features:

- **Wave System**: 15 progressive waves with difficulty scaling (+5% per
  wave), preparation phases between rounds, and boss waves (5, 10, 15)
- **Deck System** (planned): pre-select a unit set before the match starts
- **King System**: King auto-spawns at the bottom of the lane; King death
  ends the match; King HP is permanent across waves (leak damage never
  heals). Future: selectable King types with aura effects
- **Permadeath**: dead units do not return between waves — losses are
  permanent for the rest of the match
- **Auto-Combat**: AI-driven pathfinding (A*), targeting, and combat —
  units fight automatically once battle starts
- **Ability System**: mana-based abilities with auto-cast (Fireball,
  Mending Bolt, AOE), passive abilities (Warrior's Endurance), and
  projectile visuals
- **Unit Upgrades**: Legion TD-style in-place upgrades during the build
  phase — hover a placed unit and press **U** to pay the gold difference
  and replace it with its stronger form (first path: Knight → Cavalier)
- **Synergy System**: factions (Warrior / Mystic / Warden) grant stat
  bonuses when enough unique units of a faction are placed
- **Economy**: gold rewards per wave; full economy (income, interest,
  workers) to be designed after core gameplay is locked

## Current Units

### Allies (8 + King)
| Unit | Role | HP | ATK | Range | Cost | Ability |
|------|------|-----|-----|-------|------|---------|
| **Bjorn** | Warrior/Tank | 500 | 50 | Melee | 1 | Warrior's Endurance (+20% HP regen) |
| **Mage** | Ranged DPS | 400 | 40 | 3 tiles | 2 | Fireball (100 dmg, projectile) |
| **Sage** | Healer/Support | 350 | 25 | 3 tiles | 3 | Mending Bolt (heal 60 / dmg 50) |
| **Knight** | Tank | 600 | 35 | Melee | 2 | Iron Bastion (+5 armor) — upgrades to Cavalier |
| ↳ **Cavalier** | Tank (upgrade) | 1100 | 65 | Melee | 5 (2+3) | Harden Armor (-6 damage per hit, min 1) |
| **Ranger** | DPS | 300 | 30 | 4 tiles | 3 | Power Shot (120 dmg projectile) |
| **Rogue** | DPS | 250 | 70 | Melee | 3 | Deadly Focus (+25% ATK) |
| **Priest** | Support | 350 | 15 | 3 tiles | 4 | Holy Light (AoE heal 40) |
| **Druid** | Specialist | 380 | 30 | 3 tiles | 3 | Nature's Wrath (AoE 40 dmg) |
| **King** | Core | 2500 | 40 | Melee | — | *(aura effects planned)* |

### Enemies (6)
| Unit | HP | ATK | AS | Armor | MR | Range | Role |
|------|----|-----|------|-------|-----|-------|------|
| **Orc** | 100 | 10 | 0.7 | 5 | 20 | Melee | Standard warrior |
| **Necro** | 60 | 10 | 0.8 | 2 | 30 | 3 tiles | Ranged caster |
| **Goblin** | 50 | 8 | 1.2 | 2 | 10 | Melee | Fast swarm |
| **Wolf** | 60 | 12 | 1.0 | 0 | 5 | Melee | Fast flanker |
| **Troll** | 250 | 15 | 0.4 | 15 | 10 | Melee | Heavy tank |
| **Skeleton Archer** | 70 | 15 | 0.9 | 3 | 5 | 3 tiles | Ranged DPS |

## Project Structure

```
scenes/
  arena/        # Main arena scene, UI panels, battle orchestration
  unit/         # Unit and EnemyUnit scenes (Area2D + visuals + combat)
  projectile/   # Ability projectile scene
  damage_number/ # Floating damage text
  wave_display/ # Wave progress UI (legacy — now in RightSidebar)
  hud/          # HudBar, RightSidebar, TimePanel, ToastManager
  menu/         # Main menu, loading, victory, game over
  unit_selection/ # Bottom panel with unit cards
  synergy_panel/  # Synergy HUD (legacy — now in RightSidebar)

components/
  battle_manager.gd   # State machine: PREPARATION -> BATTLE -> ENDED
  wave_manager.gd     # Wave progression, enemy spawning, between-wave flow
  unit_ai.gd          # A* pathfinding, targeting, attack logic
  unit_grid.gd        # Grid-based tile occupation tracking
  unit_mover.gd       # Drag-and-drop between play areas
  unit_spawner.gd     # Runtime unit instantiation
  unit_visuals.gd     # Shared visual helpers (health bar, flashes, damage numbers)
  unit_animator.gd    # Procedural idle/walk/attack/death animations
  play_area.gd        # TileMap-based play zone
  drag_and_drop.gd    # Mouse drag input handling
  tile_highlighter.gd # Tile highlight feedback
  outline_highlighter.gd # Unit outline shader control
  velocity_based_rotation.gd # Rotation during drag movement
  synergy_manager.gd  # Faction synergy tracking and bonuses
  projectile_pool.gd  # Object pool for projectiles
  unit_utils.gd       # Shared unit-interface helpers

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
1. **Preparation Phase** — Place/reposition defenders on the grid
2. **Battle Phase** — AI takes over: pathfinding, targeting, attacks, abilities
3. **Wave Complete** — Enemies cleared, gold/XP rewards distributed
4. **Between-Wave Prep** — 30s timer (skippable); **dead units do NOT return**
   (permadeath); surviving units return to saved positions and stats reset
5. **Repeat** until all waves cleared or King HP reaches 0

### Permadeath
Unlike Legion TD 2 (where defenders revive each wave), TJT units that die
during a match stay dead for the rest of the match. This makes deck
composition and positioning critical — losing your tank on wave 3 means
fighting waves 4-15 without it.

### King System
- King auto-spawns at the bottom-center of the lane
- King HP never resets between waves — leak damage is permanent
- King death ends the match
- King does not count against the deployed unit limit
- **Planned**: selectable King types with aura effects on defenders

### Leak System (planned)
When an enemy reaches the King:
1. Enemy deals leak damage to King
2. Enemy is removed
3. King HP is permanently reduced
4. Match ends only when King HP reaches 0

### AI System
- A* pathfinding on grid with obstacle avoidance
- Aggro range-based targeting (closest enemy within range)
- Automatic attack cooldowns based on attack_speed stat
- Ability auto-cast when mana reaches max
- Anti-overkill / anti-overheal threat tracking
- Stuck detection and alternate target selection
- Separation and avoidance steering
- Debug logging with `DEBUG_AI = true` flag

### Damage Calculation (planned)
- Physical: `damage * (100 / (100 + armor))`
- Magical: `damage * (100 / (100 + magic_resist))`
- Healing: direct HP restoration

### Regeneration
- Float-based HP/mana regen during BATTLE phase only
- Delta-time independent for smooth frame-rate-safe regeneration

### Unit Stats
Each unit has the following stats (configured in .tres files):
- `max_health` & `health_regen`: hit points and regeneration rate
- `max_mana`, `starting_mana`, & `mana_regen`: resource for abilities
- `attack_damage`, `ability_power`: damage scaling
- `attack_speed`: attacks per second
- `armor`, `magic_resist`: damage reduction
- `attack_range`, `aggro_range`: combat ranges
- `tier`: unit tier (1-7)
- `faction`: Warrior / Mystic / Warden (for synergies)
- `is_king`: marks the King unit
- `visual_scale`: render scale (King is 1.5x)

## Requirements

- Godot Engine 4.7+ (GL Compatibility renderer)
- Viewport: 960x540, window: 1920x1080
- Integer scaling, pixel-perfect 2D snapping

## How to Run

1. Clone the repository
2. Open in Godot Engine 4.7+
3. Import via `project.godot`
4. Run — main scene is the Main Menu, which loads the Arena

## Controls

- **Left click** — Select / drag units, place from panel
- **Right click / Escape** — Cancel drag / placement
- **Right click on placed unit** — Remove (refunds gold)
- **U on hovered unit** — Upgrade in place (prep phase, if an upgrade exists)
- **Shift + click** — Multi-place same unit type
- **Middle click drag** — Pan camera
- **Mouse wheel** — Zoom camera (0.5x - 2.0x)
- **Start Battle button** — Begin wave / skip preparation timer

## Roadmap

- [ ] **Deck-building** — pre-match unit set selection
- [ ] **King selection** — choose King type with aura effects
- [ ] **Permadeath** — units do not revive between waves
- [ ] **Leak mechanic** — enemies damage King on contact, then despawn
- [~] **Unit upgrades** — per-unit upgrade paths (Legion TD-style); Knight → Cavalier done, more paths to come
- [ ] **Economy** — income, interest, workers (designed after core gameplay)
- [ ] **Multiplayer** — 1v1 / 2v2 / 3v3 / 4v4 / coop
- [ ] **PvP unit sending** — send units from your deck to opponent (no barracks)
- [ ] **Map / lane design** — multiple arena layouts

## License

See LICENSE file for details.

---
*Built with Godot Engine 4.7 — Last updated: August 2026*
