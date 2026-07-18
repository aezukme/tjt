# TJT Game Design Document v1.0

This document serves as the authoritative source for TJT's design vision, core mechanics, and development roadmap. It ensures the project maintains its Legion TD identity and doesn't drift into other genres (TFT, Vampire Survivors, RTS, MOBA).

Document Structure:

# 1. High Concept

**TJT**

Multiplayer wave-defense strategy game inspired by Legion TD 2.

Players build armies during preparation phases, defend their King from incoming waves, develop economic advantages, and outplay opponents through positioning, synergies, and strategic resource management.

Target Modes:

* 1v1
* 2v2 (future)

Engine:

* Godot 4.6

Platform:

* PC

Genre:

* Multiplayer Strategy
* Auto Combat
* Wave Defense

---

# 2. Pillars

This is the most important section of the GDD.

### Pillar 1 — Strategy Over Reflexes

The winner should be smarter, not faster. Combat is automated; decisions happen during preparation phases.

### Pillar 2 — Economy Matters

Saving gold is as important as spending gold. Interest system rewards strategic saving.

### Pillar 3 — Positioning Wins Games

Unit arrangement matters more than raw DPS. Frontline, backline, and flanking create tactical depth.

### Pillar 4 — Predictable, Learnable Waves

Players learn wave patterns. No random compositions; waves are designed and balanced.

### Pillar 5 — Multiplayer Fairness

No RNG decides matches. Deterministic combat, visible information, equal starting conditions.

---

# 3. Core Gameplay Loop

```text
Preparation Phase
    ↓
Buy Units
    ↓
Position Units
    ↓
Start Wave
    ↓
Automated Combat
    ↓
Leak Resolution
    ↓
King Damage
    ↓
Rewards
    ↓
Income Calculation
    ↓
Next Wave
```

---

# 4. Match Structure

### Early Game (Waves 1-5)

Focus:
- Basic economy (gold management, interest)
- Basic frontline (tanks vs DPS positioning)
- Learning unit roles and abilities

### Mid Game (Waves 6-10)

Focus:
- Synergy optimization (Warrior/Mystic/Warden bonuses)
- Counter-building (adapting to wave compositions)
- King health management (leak consequences)

### Late Game (Waves 11-15)

Focus:
- Build optimization (maximizing DPS efficiency)
- Leak management (surviving with low King HP)
- King pressure (enemy waves designed to break defenses)

---

# 5. Economy

## Gold

Used for:
- Purchasing units (current cost range: 1-4 gold)
- Future: unit upgrades
- Future: special abilities/items

## Income

Received each wave completion.

Formula:
```
Base Income
+ Bonus Income (from waves)
+ Interest (on saved gold)
```

## Interest System (Planned)

Formula:
```
10 saved gold = +1 income
20 saved gold = +2 income
30 saved gold = +3 income
```

Cap: +10 income maximum

This rewards strategic saving and creates economy management depth.

---

# 6. King System

The King represents the player's lives.

Characteristics:
- No HP regeneration (health_regen = 0)
- Damage is permanent between waves
- Death = instant Game Over
- Must be visible in HUD throughout the match

Current Implementation:
- King auto-spawns at bottom-center of GameArea
- 2500 HP, 40 ATK, 0.5 AS, 8 Armor, 25 MR
- Visual scale 1.5× for prominence
- Unsellable and unremovable
- Does not count against max deployed units limit

---

# 7. Leak System

When enemy bypasses defense:

```text
Enemy reaches King
↓
Enemy deals leak damage
↓
Enemy removed
↓
King HP reduced permanently
```

---

# 8. Factions & Synergies

### Warrior (3 units required)

Units: Bjorn, Knight, Rogue

Bonus: +20% Attack Damage

### Mystic (3 units required)

Units: Mage, Sage, Druid

Bonus: +20% Ability Power

### Warden (2 units required)

Units: Ranger, Priest

Bonus: +15% Attack Speed

Current Implementation:
- SynergyManager tracks placed units and applies/removes bonuses live
- SynergyPanel HUD shows active/pending synergies with ●●○ indicators
- All ally units have faction assignments in UnitStats resources

---

# 9. Unit Classes

### Tank

Units: Bjorn, Knight

Role: High HP, frontline, absorb damage

### DPS

Units: Mage, Ranger, Rogue

Role: Damage dealers, ranged and melee variants

### Support

Units: Sage, Priest

Role: Healing, sustain, team utility

### Specialist

Units: Druid

Role: AoE damage, unique mechanics

---

# 10. Wave Design

## Wave Categories

### Swarm

Many weak enemies.

### Tank

Few strong enemies.

### Mixed

Combination of both.

### Boss

Major test of player build.

---

# 11. Multiplayer Architecture

### Authority

Server-authoritative.

### Clients

Visual representation only.

### Sync

Synchronize:

* Purchases
* Sales
* Unit placement
* Wave start
* Economy

Do NOT synchronize:

* Pure visual effects

---

# 12. Content Roadmap

## Milestone 1 — Core Gameplay

Status: 90%

Completed:
- Build/Battle/End loop
- Wave system (15 waves)
- Unit placement (8 units max)
- Ability system (8 abilities)
- Combat AI with A* pathfinding
- King system
- Faction/synergy system
- Procedural animations

Remaining:
- Income/interest system
- HUD polish

## Milestone 2 — Economy Complete

Status: 40%

Completed:
- Gold costs
- Wave rewards
- Unit selling (full refund)

Remaining:
- Income per wave
- Interest on saved gold
- Gold HUD visibility
- Mythium system (future)

## Milestone 3 — Multiplayer Foundation

Status: 10%

Completed:
- Server-authoritative architecture planned
- Scene-based architecture
- Signal-driven systems

Remaining:
- Network sync implementation
- Dedicated server support
- 2v2 support
- Replay system

## Milestone 4 — Beta

Status: 0%

Remaining:
- Full multiplayer implementation
- Balance testing
- Content polish
- UI/UX refinement

---

# 13. Technical Architecture

### Managers
- BattleManager: State machine (PREPARATION/BATTLE/ENDED)
- WaveManager: Wave progression, enemy spawning, rewards
- SynergyManager: Faction tracking, bonus application

### Components
- UnitAI: A* pathfinding, targeting, combat logic
- UnitAnimator: Procedural animations (IDLE/WALK/ATTACK/DEATH)
- UnitVisuals: Health bars, damage numbers, visual feedback
- UnitGrid: Tile occupation tracking
- UnitMover: Drag-and-drop placement
- ProjectilePool: Object pooling for abilities

### Data
- UnitStats: Unit configuration (.tres resources)
- WaveConfig: Wave composition and difficulty
- Ability Resources: Ability definitions and parameters
- PlayerStats: Gold, XP, economy data

---

# 14. UX Principles

### Always Visible

* Gold
* Income
* Wave Number
* King HP

### Never Hidden

* Synergies
* Upcoming Wave
* Leak Damage

---

# 15. Long-Term Vision

Release Goal:

A multiplayer Godot game that captures the strategic depth of Legion TD 2 while remaining approachable and maintainable for a small development team.

---

This GDD is mandatory before multiplayer development. Every new feature must be evaluated against this document by asking:

> "Does this align with the GDD?"

This prevents the project from becoming a confused mix of Legion TD, TFT, RPG, and generic tower defense without clear identity.

---

# 16. Current Implementation Status

## Implemented Units (8 Allies + King)
| Unit | Faction | Role | Cost | Ability |
|------|---------|------|------|----------|
| Bjorn | Warrior | Tank | 1💰 | Warrior's Endurance (+20% regen) |
| Knight | Warrior | Tank | 2💰 | Iron Bastion (+5 armor) |
| Mage | Mystic | DPS | 2💰 | Fireball (100 dmg projectile) |
| Sage | Mystic | Support | 3💰 | Mending Bolt (heal 60 / dmg 50) |
| Druid | Mystic | Specialist | 3💰 | Nature's Wrath (AoE 40 dmg) |
| Ranger | Warden | DPS | 3💰 | Power Shot (120 dmg projectile) |
| Rogue | Warrior | DPS | 3💰 | Deadly Focus (+25% ATK) |
| Priest | Warden | Support | 4💰 | Holy Light (AoE heal 40) |
| King | — | — | — | *(none yet)* |

## Implemented Enemies (6)
| Unit | HP | ATK | AS | Range | Role |
|------|----|-----|------|-------|------|
| Orc | 100 | 10 | 0.7 | 1 | Standard warrior |
| Necro | 60 | 10 | 0.8 | 3 | Ranged caster |
| Goblin | 50 | 8 | 1.2 | 1 | Fast swarm |
| Wolf | 60 | 12 | 1.0 | 1 | Fast flanker |
| Troll | 250 | 15 | 0.4 | 1 | Heavy tank |
| Skeleton Archer | 70 | 15 | 0.9 | 3 | Ranged DPS |

## Technical Stack
- **Engine**: Godot 4.6+
- **Language**: GDScript (typed)
- **Architecture**: Scene-based, composition over inheritance
- **Renderer**: GL Compatibility
- **Viewport**: 960×540
- **Window**: 1920×1080

---

*Last Updated: July 2026*
