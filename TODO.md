# TODO List — TJT (Legion TD-style Tower Defense)

> **Game Design:** Players place defender units on their lane during a build phase,
> then enemy waves march in and fight automatically. Survive all waves to win.
> Inspired by *Legion TD* (WC3) / *Legion TD 2*, NOT autobattlers like TFT.

---

## ✅ Completed Systems

### Core Game Loop ✅
- [x] Build phase → Battle phase → Reward → Repeat
- [x] BattleManager with 3 states (PREPARATION / BATTLE / ENDED)
- [x] Main Menu → Arena → Victory / Game Over screens
- [x] Start Battle button (also skips prep timer between waves)

### Wave System ✅
- [x] WaveManager with 4 configurable waves + boss wave
- [x] WaveConfig resources with EnemyGroup composition
- [x] Progressive difficulty scaling (+5% per wave)
- [x] 30-second prep timer between waves (skippable)
- [x] Ally positions saved before battle, restored after
- [x] Full stat reset (HP, mana, cooldowns, AI state) between rounds
- [x] Gold + XP rewards per wave completion
- [x] Victory when all waves cleared / Game Over when all allies die

### Unit Placement ✅
- [x] Bottom panel with unit cards (name, sprite, stats, gold cost)
- [x] Click card → click tile to place (ghost sprite preview)
- [x] Ghost tints green (free) / red (occupied)
- [x] Gold cost displayed on cards, affordability check + dimming
- [x] Gold deducted on placement, auto-cancel if can't afford more
- [x] Max deployed units limit (5)
- [x] Sell portal (drag or quick-sell, refunds gold_cost × tier)

### Ability System ✅
- [x] Base Ability resource with targeting, cooldown, range
- [x] PassiveAbility for permanent stat bonuses
- [x] Fireball — single target, 100 dmg, 200 range, projectile
- [x] Mending Bolt — heal lowest ally 60 HP, or damage enemy 50 if all full
- [x] Heal — self heal 30 HP
- [x] Arcane Explosion — AoE 25 dmg to all enemies
- [x] Warrior's Endurance — passive +20% health regen
- [x] Mana system (gain per attack, cast when full)

### Combat AI ✅
- [x] Aggro-range based target finding
- [x] A* pathfinding on unit grid
- [x] Threat tracking (incoming_damage / incoming_healing)
- [x] Anti-overkill: prefer targets with effective HP > 0
- [x] Anti-overheal: prefer allies with effective missing HP > 0
- [x] Separation force to prevent unit stacking
- [x] Enemy dummy target (walk toward player base when no target)

### Visual Feedback ✅
- [x] Damage numbers (float up + fade, scaled by damage)
- [x] Fireball projectile (smooth flight, hit detection, color)
- [x] Health bars + mana bars on all units
- [x] Unit skin flash on hit
- [x] Wave display UI (wave counter, enemy count, progress bar, timer)
- [x] Unit stats panel (live HP/mana for each ally)

### Bug Fixes Applied ✅
- [x] Lambda capture freed errors (WeakRef pattern)
- [x] AI spam during PREPARATION (battle state guard)
- [x] remaining_enemies going to -1 (double-decrement guard)
- [x] Freed object cast in UnitGrid.remove_unit (is_instance_valid guard)
- [x] handle_unit_death validity check
- [x] BattleManager type casting issues
- [x] Mana regeneration system (battle state check)

---

## 🔥 High Priority — Next Up

### More Defender Units
- [ ] Need 8–12 ally unit types for build variety (currently 3)
- [ ] **Tank line:** Bjorn (done), add Knight or Paladin (high armor, taunt?)
- [ ] **DPS line:** Mage (done), add Archer (fast attack, low HP), Assassin (high single-target)
- [ ] **Support line:** Sage (done), add Bard (AoE buff?), Druid (summons?)
- [ ] **Specialist:** Trapper (slows enemies?), Necromancer (raises dead?)
- [ ] Each unit needs: .tres stats, unique ability, balanced gold cost
- [ ] Unit tier/upgrade system (combine 3 of same → tier 2, stronger stats)

### More Enemy Types
- [ ] Need 5–8 enemy types for wave variety (currently 2: Orc, Necro)
- [ ] **Fast:** Goblin / Wolf — low HP, high speed, swarms
- [ ] **Tank:** Troll / Golem — high HP, slow, armor
- [ ] **Ranged DPS:** Skeleton Archer — ranged, medium HP
- [ ] **Healer:** Shaman — heals other enemies
- [ ] **Boss:** Dragon / Demon Lord — very high HP, special ability, appears on boss waves
- [ ] Flying enemies? (bypass melee, only ranged can hit)

### More Waves & Difficulty Curve
- [ ] Expand from 4 to 15–20 waves for a full game
- [ ] Wave generator improvements (random composition per run?)
- [ ] Increasing enemy variety as waves progress
- [ ] Boss every 5th wave with unique mechanics
- [ ] Wave preview (show what's coming before build phase)
- [ ] Income system between waves (base gold + interest on saved gold?)

### Lane / Positioning System (Legion TD Core)
- [ ] Enemies walk a fixed path (top to bottom through player's lane)
- [ ] Player units are static defenders (no movement during battle)
- [ ] Enemies that reach the end of the lane deal damage to player lives
- [ ] Player lives system (start with N lives, lose 1 per leaked enemy)
- [ ] Multiple lanes? (future — multiplayer prep)

---

## 🎯 Medium Priority

### Combat Improvements
- [x] Target stickiness (units commit to current target while alive + in range)
- [x] Target switch delay (0.8s lock prevents erratic switching)
- [ ] Tank aggro system (enemies prefer attacking nearest/taunting unit)
- [ ] Attack priority options (closest, lowest HP, highest threat)
- [ ] Critical hit system
- [ ] Status effects (slow, stun, poison, burn)
- [ ] Armor/Magic Resist damage reduction formulas + tooltips
- [ ] AoE/splash damage for certain units
- [ ] Lifesteal mechanic

### Gold & Economy
- [ ] Income per wave (base + interest on banked gold, like Legion TD)
- [ ] Gold display always visible in HUD
- [ ] Unit sell value decay (sell for less than buy price?)
- [ ] Balance gold costs vs wave rewards curve

### Build Phase UX
- [x] Right-click to remove placed units (refunds full gold cost)
- [ ] Drag units to reposition during build phase
- [ ] Unit tooltip on hover (full stats, ability description)
- [ ] Undo last placement button
- [ ] Quick-buy hotkeys (1-9 for unit types)
- [ ] Show ability info on selection card

### Wave / Battle UX
- [ ] Wave preview panel (show enemy types + count before battle starts)
- [ ] Speed up / fast forward button during battle
- [ ] Auto-start next wave option
- [ ] Battle replay / combat log

---

## 📦 Low Priority / Nice to Have

### Visual Polish
- [ ] Unit death animations (fade out, particles)
- [ ] Melee hit effects (slash sprite)
- [ ] Ability cast animations
- [ ] Screen shake on boss spawn / big hits
- [ ] Attack animations (sprite flipping/bobbing)
- [ ] Particle effects for status effects
- [ ] Better backgrounds / arena tilemap art

### Audio
- [ ] Battle music
- [ ] Attack sound effects per unit type
- [ ] Ability cast sounds
- [ ] Gold spend / earn sound
- [ ] Victory / defeat jingles
- [ ] UI click sounds
- [ ] Volume controls

### Meta / Progression
- [ ] High score tracking (waves survived, gold earned)
- [ ] Save/Load system
- [ ] Player statistics
- [ ] Unlockable units / skins
- [ ] Different arena maps / layouts
- [ ] Daily challenges

### Performance
- [x] Object pooling for projectiles
- [x] Optimize AI search frequency (cached BattleManager refs)
- [x] Loading screen with tips (threaded scene loading)
- [x] Y-sort z-index for unit depth ordering
- [x] Rectangular aggro range (allies only — wider X, narrower Y)

---

## 🐛 Known Issues / Tech Debt
- [ ] `[WAVE] WARNING: Could not find PlayerStats node!` on startup (harmless, timing issue)
- [x] ~~`[dummy] → [dummy]` target change spam~~ (dummy target reused instead of recreated)
- [x] ~~`[Ability] No valid targets` fireball spam~~ (moved to verbose logging)
- [ ] `target changed Sage → Sage` log noise (same-name different instances)
- [ ] `[Ability] Sage ability ready!` × 5 spam when multiple units ready simultaneously
- [ ] Fix sage_ally.tres UID warning (uid://dh3al0rharm01)
- [ ] Consistent naming conventions (snake_case vs PascalCase)
- [ ] Warrior's Endurance passive stacking on each unit placement (regen compounds)

---

## 📊 Current Content

### Ally Units (3)
| Unit | HP | ATK | Range | Cost | Ability |
|------|----|-----|-------|------|---------|
| Bjorn (Warrior) | 500 | 50 | 1 (melee) | 1💰 | Warrior's Endurance (+20% regen) |
| Mage | 400 | 40 | 3 (ranged) | 2💰 | Fireball (100 dmg projectile) |
| Sage (Healer) | 350 | 25 | 3 (ranged) | 3💰 | Mending Bolt (heal 60 / dmg 50) |

### Enemy Units (2)
| Unit | HP | ATK | Range |
|------|----|-----|-------|
| Orc | 100 | 10 | 1 (melee) |
| Necro | 60 | 10 | 3 (ranged) |

### Waves (4)
| Wave | Enemies | Reward |
|------|---------|--------|
| 1 — First Blood | 3× Orc | 50💰, 10 XP |
| 2 — Reinforcements | 4× Orc + 2× Necro | 80💰, 20 XP |
| 3 — Assault | 3× Orc + 4× Necro + 4× Orc | 150💰, 40 XP |
| 4 — Boss Wave 👑 | 4× Necro + 4× Orc | 300💰, 80 XP |

---

## Session Log

### February 2026 (Session 3) — Gold, Overkill Fix, Polish
- ✅ Gold cost system: card display, affordability check, auto-deduct on placement
- ✅ Anti-overkill threat tracking (incoming_damage / incoming_healing)
- ✅ Fireball ability updated with threat-aware targeting
- ✅ AI log spam reduced (verbose mode toggle)
- ✅ Freed object cast fix in UnitGrid.remove_unit
- ✅ handle_unit_death validity guard

### February 2026 (Session 2) — Menus, Unit Selection, Waves
- ✅ Main Menu, Victory Screen, Game Over Screen
- ✅ Unit selection panel with click-to-place + ghost sprite
- ✅ Wave system: 4 waves, prep timer, position save/restore, stat reset
- ✅ Sage healer unit with Mending Bolt (heal/harm dual mode)
- ✅ HealOrHarmAbility class
- ✅ Lambda capture fixes (WeakRef pattern)
- ✅ UI: Arial system font, compact panels, wave display
- ✅ Fixed AI spam, remaining_enemies going negative

### November 2025 (Session 1) — Foundation
- ✅ Damage number system
- ✅ Complete ability system (Fireball, Heal, AoE, Passive)
- ✅ Projectile system (smooth flight, hit detection)
- ✅ Float-based health/mana regeneration
- ✅ Bug fixes (mana regen, BattleManager casting, console spam)

---
*Last Updated: February 2026*
