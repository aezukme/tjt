# TJT — Game Design Document

> **One-line pitch:** Legion TD 2 wave defense meets OCG deck-building and
> permadeath. Build a deck, pick a King, defend your lane, lose units forever.

---

# 1. High Concept

**TJT**

A hybrid strategy game that fuses **Legion TD 2** wave-defense gameplay with
**Original Card Game (OCG)** deck-building and **permadeath**.

Players build a predefined **unit deck** before the match, choose a **King**
(with future aura effects), place static defenders on their lane, and survive
progressive waves of enemies. Dead units stay dead — every loss is permanent,
so positioning and deck composition matter more than economy spam.

Target Modes:

- Single-player (wave survival) — current focus
- 1v1 (future)
- 2v2 / 3v3 / 4v2 / Coop (future)

Engine:

- Godot 4.7

Platform:

- PC

Genre:

- Strategy
- Wave Defense
- Deck-Building
- Auto Combat
- Permadeath

---

# 2. Design Identity

TJT is **not**:

- TFT-style auto-battler (no board swapping, no items, no shop reroll)
- Vampire Survivors / RTS / MOBA

TJT **is**:

- Legion TD 2 wave defense (static defenders, progressive waves, King defense)
- OCG deck-building (predefined unit set chosen before the match)
- Permadeath (units that die in a match stay dead — like card games)
- King auras (planned — King type grants passive effects to defenders)
- Multiplayer-first (future 1v1 / 2v2 / 3v3 / 4v4 / coop)

## 2.1 Legion TD 2 Influences

- Static defenders placed on a lane during build phase
- Progressive, learnable wave patterns (15 waves, boss every 5th)
- Unit tiers (currently up to 7) and per-unit upgrade paths (planned)
- King as the player's life — leak damage is permanent
- Map / lane design (expanding with multiplayer in mind)
- Sending units to opponents in PvP (planned — sent from your personal
  predefined deck, **no separate mercenary barracks**)

## 2.2 Where Legion TD Influence Ends

- **Deck-building**: each player pre-selects a unit set before the match,
  similar to an OCG deck. You fight with what you brought.
- **King selection**: players choose a King type before the match. Future
  Kings will grant aura effects to defenders.
- **Permadeath**: a unit that dies during a match is gone for the rest of
  the match. There is no respawn, no wave-reset revive. This mirrors card
  games where played cards are consumed.

---

# 3. Pillars

### Pillar 1 — Strategy Over Reflexes
The winner should be smarter, not faster.

### Pillar 2 — Every Loss is Permanent
Permadeath makes each placement decision meaningful. Losing your tank on
wave 3 means fighting waves 4-15 without it.

### Pillar 3 — Deck Composition Wins Games
What you bring to the match matters as much as how you place it.

### Pillar 4 — Positioning Wins Games
Unit arrangement must be more important than pure DPS.

### Pillar 5 — Predictable, Learnable Waves
Players should learn wave patterns.

### Pillar 6 — Multiplayer Fairness
No RNG should decide a match.

---

# 4. Core Gameplay Loop

```text
Pre-match: Build Deck + Choose King
    ↓
Preparation Phase
    ↓
Place Defenders (from deck)
    ↓
Start Wave
    ↓
Automated Combat
    ↓
Leak Resolution (enemies that reach King deal permanent damage)
    ↓
Rewards
    ↓
Next Wave (dead units do NOT return — permadeath)
    ↓
Repeat until King HP = 0 or all waves cleared
```

---

# 5. Match Structure

### Early Game — Wave 1-5
Focus:

- Basic economy
- Basic frontline
- Learn wave patterns

### Mid Game — Wave 6-10
Focus:

- Synergies
- Counter-builds
- Managing permadeath losses

### Late Game — Wave 11-15
Focus:

- Optimization with remaining deck
- Leak management
- King pressure

---

# 6. Permadeath

Unlike Legion TD 2 (where defenders revive each wave), TJT units that die
during a match stay dead for the rest of the match.

Implications:

- Deck depth matters — you need enough units to survive 15 waves
- Positioning is critical — a bad placement can cost you a key unit forever
- Tank economy is real — losing your frontline early cascades
- Healing/support units are more valuable (keeping units alive preserves them)

This mirrors OCG/card games where played cards are consumed and cannot be
reused within the same match.

---

# 7. King System

King represents the player's lives.

Characteristics:

- King HP never resets between waves — permanent damage from leaks
- King death = match over
- King must be visible in HUD at all times
- King does not count against deployed unit limit

Planned:

- **King selection**: players choose a King type before the match
- **King auras**: each King type grants passive effects to defenders
  (e.g. +armor aura, +regen aura, +attack speed aura)

---

# 8. Leak System

When an enemy passes the defense and reaches the King:

```text
Enemy reaches King
↓
Enemy deals leak damage to King
↓
Enemy is removed
↓
King HP reduced permanently
↓
Match ends only when King HP reaches 0
```

---

# 9. Deck-Building System (Planned)

Before the match, each player assembles a **deck** — a predefined set of
units they will have access to during the match.

Design goals:

- Players choose units from their collection before the match starts
- The deck limits what can be placed during build phases
- Deck composition is a strategic decision (tank-heavy? synergy-focused?
  rush-friendly?)
- In PvP, players send units from their own deck to attack opponents
  (no separate mercenary barracks — your deck IS your offense and defense)

Open questions (to resolve during design):

- Deck size limits (min/max units)
- Whether units are single-use (one copy per deck) or multi-copy
- How deck-building interacts with gold/economy during the match
- Whether the King choice modifies the deck rules

---

# 10. Factions & Synergies

### Warrior
3 unique units:
```text
+20% Attack Damage
```

### Mystic
3 unique units:
```text
+20% Ability Power
```

### Warden
2 unique units:
```text
+15% Attack Speed
```

---

# 11. Unit Classes

### Tank
Examples: Bjorn, Knight

### DPS
Examples: Ranger, Rogue, Mage

### Support
Examples: Sage, Priest

### Specialist
Examples: Druid

---

# 12. Unit Tiers & Upgrades (Planned)

Units have tiers (currently up to 7).

Planned:

- Per-unit upgrade paths (Legion TD-style)
- Each unit may have one or more upgrade options
- Upgrades are chosen during the match (strategic decision)

---

# 13. Wave Design

## Wave Categories

### Swarm
Many weak enemies.

### Tank
Few strong enemies.

### Mixed
Combination.

### Boss
Big build test.

Current waves: 15 total, with boss waves at 5, 10, 15.

---

# 14. Economy (To Be Designed)

The economy system will be designed **after** core gameplay and design
pillars are locked. This avoids building economy on top of mechanics that
may still change.

Likely components (inspired by Legion TD 2):

- Gold (spent on units and upgrades)
- Income (earned each round)
- Interest (bonus income for saved gold)
- Workers / Mythium (under consideration)

Design constraint: economy must support permadeath (losing units permanently
must interact meaningfully with gold/income).

---

# 15. Multiplayer Architecture (Future)

### Authority
Server authoritative.

### Clients
Visual representation.

### Sync
Synchronize:

- Unit placement
- Unit selling/removal
- Start wave
- Economy
- Deck composition
- King selection
- PvP unit sending

Do not synchronize:

- Pure visual effects

### PvP Unit Sending
Players send units from their **personal deck** to attack opponents.
There is **no separate mercenary barracks** — your deck is both your
defense and your offense.

---

# 16. Content Roadmap

## Milestone 1 — Core Gameplay
Status: ~90%

- Wave system (15 waves)
- Battle flow (prep -> battle -> reward)
- Unit AI (pathfinding, targeting, abilities)
- King system (basic)
- Synergy system

## Milestone 2 — Identity & Documentation
Status: in progress

- README aligned with GDD
- GDD reflects Legion TD + OCG + permadeath vision
- TODO reflects current priorities

## Milestone 3 — Permadeath & Leak
Status: 0%

- Units do not revive between waves
- Leak damage to King on enemy contact
- Game over only on King HP = 0

## Milestone 4 — Deck-Building
Status: 0%

- Pre-match unit set selection
- Deck limits and rules
- King selection

## Milestone 5 — Economy
Status: 0%

- Designed after core gameplay is locked
- Income, interest, workers (TBD)

## Milestone 6 — Unit Upgrades
Status: 0%

- Per-unit upgrade paths
- Tier progression

## Milestone 7 — Multiplayer Foundation
Status: 0%

- Server authority
- 1v1 first, then 2v2 / 3v3 / 4v4 / coop
- PvP unit sending from deck

## Milestone 8 — Beta
Status: 0%

---

# 17. Technical Architecture

### Managers
- BattleManager
- WaveManager
- SynergyManager

### Components
- UnitAI
- UnitAnimator
- UnitVisuals

### Data
- UnitStats
- WaveConfig
- Ability Resources
- PlayerStats

---

# 18. UX Principles

### Always Visible
- Gold
- Wave Number
- King HP
- Dead units (so player knows what they've lost)

### Never Hidden
- Synergies
- Upcoming Wave
- Leak Damage

---

# 19. Long-Term Vision

Release Goal:

A multiplayer Godot game that captures the strategic depth of Legion TD 2,
adds OCG-style deck-building and permadeath for higher stakes, and remains
approachable and maintainable for a small development team.

---

*Last updated: August 2026*
