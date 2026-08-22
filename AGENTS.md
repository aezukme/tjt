# AGENTS.md — TJT Project Rules for AI Agents

> **Project:** TJT — Legion TD 2 + OCG Deck-Building + Permadeath
> **Engine:** Godot 4.7 (GL Compatibility renderer)
> **Language:** GDScript (typed)

## Project Identity

TJT is a hybrid strategy game fusing:
- **Legion TD 2** wave defense (static defenders, progressive waves, King defense)
- **OCG deck-building** (predefined unit set chosen before the match)
- **Permadeath** (units that die in a match stay dead — no revive between waves)

TJT is **NOT** a TFT-style auto-battler. No board swapping, no items, no shop reroll.

See `Game Design Document.md` for full design spec.

## Communication

- Chat in Serbian (Cyrillic or Latin)
- Documentation, code, and comments in English

## Code Style

- Typed GDScript (`var x: int = 0`, not `var x = 0`)
- Composition over inheritance
- Scene-based architecture
- Signal-driven systems
- Reusable components
- Production-ready code — no placeholders
- Maintainability over cleverness
- Explain tradeoffs in comments when non-obvious
- **Console logging**: every new component or feature should log key actions to console with a `[Tag]` prefix (e.g. `[DeckManager]`, `[WAVE]`, `[Battle]`). This makes debugging easier for both developer and AI agent. Log initialization, state changes, errors, and important events.

## Architecture

### Managers (singleton-like nodes in Arena scene)
- `BattleManager` — state machine: PREPARATION → BATTLE → ENDED
- `WaveManager` — wave progression, enemy spawning, between-wave flow
- `SynergyManager` — faction synergy tracking and bonuses

### Unit system
- `Unit` (player) and `EnemyUnit` (enemy) both extend `Area2D`
- Shared components: `UnitAI`, `UnitAnimator`, `UnitVisuals`
- Stats configured via `UnitStats` resource (.tres files)
- **Damage types**: `UnitStats.DamageType.PHYSICAL`, `MAGICAL`, `PURE`
- **Armor/MR**: percentage-based reduction (15 armor = 15% less physical damage), capped at 90%
- **Mana**: per-unit `mana_regen` (no mana per attack)

### Key design rules
- **King HP = 0** is the only defeat condition. King fights alone if all other allies die.
- **Permadeath**: dead units are `queue_free()`-d and never revive between waves.
- **Leak**: enemies that reach the King fight him; King HP is permanent across waves.

## File Organization

```
scenes/      # Godot scenes (.tscn) and their scripts
components/  # Reusable GDScript components (managers, AI, helpers)
data/        # Resource files (.tres) and their scripts
  units/     # UnitStats resources
  abilities/ # Ability resources
  waves/     # WaveConfig and WaveEnemyGroup resources
asset/       # Sprites, tilesets, fonts, audio, shaders
```

## Verification

- Open project in Godot 4.7+ and run — main scene is Main Menu
- Check for parse errors in Output panel
- Test wave 1 (should be challenging: 10 goblins + 6 orcs + 5 skeleton archers)
- Verify: King death = game over, permadeath toasts appear, Victory/GameOver stats display

## Current Priorities

See `TODO.md` for current task list. Economy is deferred until PvP work begins.
