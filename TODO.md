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
- [x] Streaming enemy spawn (one-by-one, each starts walking immediately)
- [x] Enemies spawn off-grid at random X near center, free-moving from start
- [x] WaveEnemyGroup props: enemy_type, count, spawn_interval_within_group
- [x] Win condition delegates to WaveManager (remaining_enemies counter)

### Unit Placement ✅
- [x] Bottom panel with unit cards (name, sprite, stats, gold cost)
- [x] Click card → click tile to place (ghost sprite preview)
- [x] Ghost tints green (free) / red (occupied)
- [x] Gold cost displayed on cards, affordability check + dimming
- [x] Gold deducted on placement, auto-cancel if can't afford more
- [x] Max deployed units limit (8)
- [x] ~~Sell portal~~ (removed — gold refund via right-click instead)

### Ability System ✅
- [x] Base Ability resource with targeting, cooldown, range
- [x] PassiveAbility for permanent stat bonuses
- [x] Fireball — single target, 100 dmg, 200 range, projectile
- [x] Mending Bolt — heal lowest ally 60 HP, or damage enemy 50 if all full
- [x] Heal — self heal 30 HP
- [x] Arcane Explosion — AoE 25 dmg to all enemies
- [x] Warrior's Endurance — passive +20% health regen
- [x] Mana system (gain per attack, cast when full)

### King System ✅
- [x] King unit auto-spawns at bottom-center of GameArea on arena load
- [x] King death = instant Game Over ("The King has fallen!")
- [x] Enemies walk toward King position (dummy target tracks King)
- [x] King unsellable (sell portal guard) & unremovable (right-click guard)
- [x] King does NOT count against max deployed units limit
- [x] Larger visual scale (1.5×) via visual_scale property on UnitStats
- [x] is_king flag on UnitStats for identification
- [x] King stats: 2500 HP, 40 ATK, 0.5 AS, 8 Armor, 25 MR, Legendary rarity, 0 cost

### Combat AI ✅
- [x] Aggro-range based target finding
- [x] A* pathfinding on unit grid
- [x] Threat tracking (incoming_damage / incoming_healing)
- [x] Anti-overkill: prefer targets with effective HP > 0
- [x] Anti-overheal: prefer allies with effective missing HP > 0
- [x] Separation force to prevent unit stacking (anchored units resist push)
- [x] Enemy dummy target (walk toward King when no target)
- [x] Pre-move intercept (switch to enemy in attack range before walking)
- [x] Diagnostic logging with emoji markers ([AI] prefix)
- [x] Avoidance steering (steer around same-team units, hard-obstacle for fighting allies)
- [x] Stuck detection (switch to alternate target after 1.5s no progress)
- [x] Path blocker detection (enemies attack blocking ally instead of walking through)
- [x] Ally idle detection logging (⚠ IDLE warns when allies ignore combat)

### Visual Feedback ✅
- [x] Damage numbers (float up + fade, scaled by damage)
- [x] Fireball projectile (smooth flight, hit detection, color)
- [x] Health bars + mana bars on all units
- [x] Unit skin flash on hit
- [x] Wave display UI (wave counter, enemy count, progress bar, timer)
- [x] Unit stats panel (live HP/mana for each ally)

### Procedural Animation System ✅
- [x] UnitAnimator component with 4 states: IDLE, WALK, ATTACK, DEATH
- [x] Idle bob animation (1.5px, 1.5Hz sine wave)
- [x] Walk bob + tilt animation (2.5px, 4Hz, 5° lean)
- [x] Attack squash + lunge animation (0.15s, scale squash + forward lunge)
- [x] Death jump + spin + fade animation (0.4s)
- [x] AnimatedSprite2D support (auto-plays named animations when sprite_frames set)
- [x] Wired into unit_ai.gd (walk on move, attack on strike, idle on cooldown/no target)
- [x] Death animation plays before unit removal
- [x] Idle animation runs during PREPARATION phase

### Camera & QoL ✅
- [x] Camera2D with mouse scroll zoom (0.5×–2.0×, 0.1 step)
- [x] Middle-click camera pan (drag to move camera, zoom-scaled)
- [x] Shift+click multi-place (hold Shift to keep placing same unit type)
- [x] Drag card to grid placement (drag from card, release on tile to place)
- [x] Click outside panel closes it (left-click on arena hides unit selection panel)

### Bug Fixes Applied ✅
- [x] Lambda capture freed errors (WeakRef pattern)
- [x] AI spam during PREPARATION (battle state guard)
- [x] remaining_enemies going to -1 (double-decrement guard)
- [x] Freed object cast in UnitGrid.remove_unit (is_instance_valid guard)
- [x] handle_unit_death validity check
- [x] BattleManager type casting issues
- [x] Mana regeneration system (battle state check)
- [x] Enemy separation pushing fighters off targets (anchoring fix)
- [x] check_win_condition false positive with grid-free enemies (WaveManager delegation)
- [x] Wave completing instantly when enemies spawn off-grid (remaining_enemies counter)
- [x] Attack tween squash bug — interrupted attack left units squashed (scale + position reset in _kill_attack_tween)
- [x] King shrinking after first battle — _base_scale captured before visual_scale applied (re-capture after set_stats)
- [x] Idle animation float precision — _idle_time wrapped with fmod to prevent drift over long sessions
- [x] Attack→idle transition — _idle_time now resets when returning to idle from attack tween

---

## ⚡ Legion TD 2 Core Systems — Missing

> These are the mechanics that define the Legion TD genre. Without them the game is
> a basic tower defense; with them it becomes a strategic economy game.

### 1. King Lives / Leak Mechanic ✅ (partially done)
- [x] King HP never resets between waves — permanent damage from leaks
- [x] King health_regen = 0 (no self-healing)
- [ ] Game Over only when King HP reaches 0
- [ ] King HP bar visible in HUD at all times
- [ ] Current behavior (King dies = instant Game Over) 

### 4. Faction / Synergy System ✅
- [x] Units belong to factions: Warrior (Knight, Bjorn, Rogue), Mystic (Mage, Sage, Druid), Warden (Ranger, Priest)
- [x] Placing 3+ Warriors → +20% ATK damage; 3+ Mystics → +20% AP; 2+ Wardens → +15% ATK speed
- [x] SynergyManager component tracks placed units, applies/removes stat bonuses live
- [x] SynergyPanel HUD shows active/pending synergies (dots ●●○ style)
- [x] Faction field added to UnitStats; all ally .tres files updated
- [ ] Faction icon shown on unit cards in UnitSelectionPanel

### 5. Wave Preview / Info System ✅
- [x] After each wave completes, prep-phase shows next wave's enemy composition
- [x] Format: "Next: 3× Orc, 2× Troll" via NextWaveLabel in WaveDisplay
- [x] WaveManager.get_next_wave_config() added
- [ ] Enemy icons with HP/ATK/count displayed (currently text-only)

### 6. Income & Gold HUD 🟢 (MEDIUM)
- [ ] Gold always visible in HUD (not just on unit selection panel)
- [ ] Income breakdown tooltip: base + workers + interest = total next wave
- [ ] Mythium always visible next to gold
- [ ] King HP / Lives always visible in HUD

---

## 🔥 High Priority — Next Up

- [x] ~~IMPORTANT: Fix aggro, AI movement, pathfinding, and targeting~~ (anchoring, avoidance steering, stuck detection, blocker detection)
- [ ] Enemy target switching still needs tuning (debug logs added)
- [ ] Ally back-row engagement (Y aggro multiplier increased 1.0→2.0, needs testing)

### More Defender Units ✅
- [x] Need 8–12 ally unit types for build variety (currently 8)
- [x] **Tank line:** Bjorn (done), Knight (high armor, Iron Bastion passive)
- [x] **DPS line:** Mage (done), Ranger (fast ranged, Power Shot), Rogue (high melee burst, Deadly Focus)
- [x] **Support line:** Sage (done), Priest (AoE Holy Light heal)
- [x] **Specialist:** Druid (Nature's Wrath AoE damage)
- [x] Each unit has: .tres stats, unique ability/passive, balanced gold cost

### More Enemy Types ✅
- [x] Need 5–8 enemy types for wave variety (now 6: Orc, Necro, Goblin, Wolf, Troll, Skeleton Archer)
- [x] **Fast:** Goblin — low HP (50), high attack speed (1.2), swarms
- [x] **Fast Flanker:** Wolf — low HP (60), high aggro range (9), flanks backline
- [x] **Tank:** Troll — high HP (250), slow (0.4 AS), heavy armor (15)
- [x] **Ranged DPS:** Skeleton Archer — ranged (3), medium HP (70), high aggro (8)
- [ ] **Healer:** Shaman — heals other enemies
- [ ] **Boss:** Dragon / Demon Lord — very high HP, special ability, appears on boss waves

### More Waves & Difficulty Curve ✅
- [x] Expand from 4 to 15 waves for a full game
- [x] Increasing enemy variety as waves progress (new types introduced gradually)
- [x] Boss every 5th wave (Wave 5: Troll Assault, Wave 10: The Warhost, Wave 15: The Last Stand)
- [ ] Wave generator improvements (random composition per run?)
- [ ] Wave preview (show what's coming before build phase)
- [ ] Income system between waves (base gold + interest on saved gold?)

### Lane / Positioning System (Legion TD Core)
- [x] Enemies walk toward King (replaces traditional lives system)
- [x] King death = Game Over (no lives counter needed)
- [x] Enemies stream in from top of lane, walk toward King
- [ ] Player units are static defenders (no movement during battle)
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
- [ ] ~~Income per wave (base + interest on banked gold, like Legion TD)~~ → see Legion TD 2 Core Systems above
- [ ] Gold display always visible in HUD → see HUD section above
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
- [x] Unit death animations (fade out, particles) — procedural death (jump+spin+fade)
- [ ] Melee hit effects (slash sprite)
- [x] Ability cast animations — attack squash+lunge procedural
- [ ] Screen shake on boss spawn / big hits
- [x] Attack animations (sprite flipping/bobbing) — procedural walk bob+tilt, attack squash+lunge
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
- [x] Warrior's Endurance passive stacking on each unit placement — FIXED (guard flag + stats order)

---

## 📊 Current Content

### Ally Units (8 + King)
| Unit | HP | ATK | AS | Range | Cost | Ability |
|------|----|-----|------|-------|------|------|
| Bjorn (Warrior) | 500 | 50 | 0.7 | 1 (melee) | 1💰 | Warrior's Endurance (+20% regen) |
| Mage | 400 | 40 | 0.8 | 3 (ranged) | 2💰 | Fireball (100 dmg projectile) |
| Sage (Healer) | 350 | 25 | 0.6 | 3 (ranged) | 3💰 | Mending Bolt (heal 60 / dmg 50) |
| Knight (Tank) | 600 | 35 | 0.6 | 1 (melee) | 2💰 | Iron Bastion (+5 armor) |
| Ranger (DPS) | 300 | 30 | 1.2 | 4 (ranged) | 3💰 | Power Shot (120 dmg projectile) |
| Rogue (DPS) | 250 | 70 | 1.0 | 1 (melee) | 3💰 | Deadly Focus (+25% ATK) |
| Priest (Support) | 350 | 15 | 0.5 | 3 (ranged) | 4💰 | Holy Light (AoE heal 40) |
| Druid (Specialist) | 380 | 30 | 0.7 | 3 (ranged) | 3💰 | Nature's Wrath (AoE 40 dmg) |
| **King** 👑 | **2500** | 40 | 0.5 | 1 (melee) | — | *(none yet — auras/abilities TBD)* |

### Enemy Units (6)
| Unit | HP | ATK | AS | Armor | MR | Range | Role |
|------|----|-----|------|-------|-----|-------|------|
| Orc | 100 | 10 | 0.7 | 5 | 20 | 1 (melee) | Standard warrior |
| Necro | 60 | 10 | 0.8 | 2 | 30 | 3 (ranged) | Ranged caster |
| Goblin | 50 | 8 | 1.2 | 2 | 10 | 1 (melee) | Fast swarm |
| Wolf | 60 | 12 | 1.0 | 0 | 5 | 1 (melee) | Fast flanker |
| Troll | 250 | 15 | 0.4 | 15 | 10 | 1 (melee) | Heavy tank |
| Skeleton Archer | 70 | 15 | 0.9 | 3 | 5 | 3 (ranged) | Ranged DPS |

### Waves (15)
| Wave | Name | Enemies | Reward |
|------|------|---------|--------|
| 1 | First Blood | 6× Goblin | 30💰, 5 XP |
| 2 | Orc Warband | 6× Orc | 50💰, 10 XP |
| 3 | Wolf Pack | 4× Wolf + 6× Goblin | 60💰, 15 XP |
| 4 | Bone Rain | 3× Skeleton Archer + 4× Orc | 70💰, 20 XP |
| **5** | **BOSS: Troll Assault 👑** | **2× Troll + 8× Orc** | **120💰, 35 XP** |
| 6 | Dark Magic | 4× Necro + 6× Goblin | 80💰, 25 XP |
| 7 | Feral Onslaught | 8× Wolf + 3× Skeleton Archer | 90💰, 30 XP |
| 8 | Siege Line | 6× Orc + 2× Troll + 4× Necro | 100💰, 35 XP |
| 9 | Arrow Storm | 5× Skeleton Archer + 8× Wolf | 110💰, 40 XP |
| **10** | **BOSS: The Warhost 👑** | **4× Troll + 6× Necro + 8× Orc** | **200💰, 60 XP** |
| 11 | Goblin Horde | 10× Goblin + 5× Skeleton Archer | 130💰, 45 XP |
| 12 | Undead Legion | 6× Necro + 4× Orc + 2× Troll | 140💰, 50 XP |
| 13 | The Wild Hunt | 8× Wolf + 4× Troll + 3× Skeleton Archer | 160💰, 55 XP |
| 14 | Total War | 8× Orc + 6× Necro + 4× Wolf + 4× Troll | 180💰, 65 XP |
| **15** | **FINAL: The Last Stand 👑** | **4× Troll + 5× Skeleton Archer + 10× Goblin + 6× Necro** | **500💰, 100 XP** |

---

## Session Log

### May 2026 (Session 7) — Legion TD 2 Core Systems
- ✅ TODO updated with full Legion TD 2 structural analysis
- ✅ King HP never resets between waves (permanent damage from leaks)
- ✅ King health_regen = 0 (no self-healing)
- ✅ Wave Preview: after each wave, prep-phase shows next wave composition ("Next: 3× Orc, 2× Troll")
- ✅ Faction Synergy system: Warrior/Mystic/Warden factions with stat bonuses
- ✅ SynergyManager component: tracks placed units, applies/removes bonuses live
- ✅ SynergyPanel HUD: shows active/pending synergies with ●●○ style indicators
- ✅ All ally .tres files updated with faction assignments

### April 2026 (Session 6) — Animation, Camera, QoL, Bug Fixes
- ✅ Procedural UnitAnimator system added (IDLE, WALK, ATTACK, DEATH)
- ✅ Idle bob, walk bob+tilt, attack squash+lunge, death jump+spin+fade
- ✅ AnimatedSprite2D support prepared for future sprite sheet animations
- ✅ Camera2D added with mouse-wheel zoom and middle-click pan
- ✅ Shift+click multi-place and drag-card-to-grid placement implemented
- ✅ Click outside unit panel closes it
- ✅ Fixed King size shrink bug after first battle (base scale recaptured)
- ✅ Added idle animation stability fix for long sessions
- ✅ Added attack→idle transition reset so idle phase restarts cleanly

### February 2026 (Session 5) — King Unit, Arena Expansion
- ✅ **King unit** — core game mechanic: death = Game Over
- ✅ King auto-spawns at bottom-center of GameArea on arena load
- ✅ Enemies walk toward King position (dummy target tracks King)
- ✅ King unsellable & unremovable (sell portal + right-click guards)
- ✅ King visual_scale 1.5× (applied to $Visuals node, survives wave resets)
- ✅ is_king flag + visual_scale property added to UnitStats
- ✅ Arena expansion: Background 30×17, GameArea 18×12, EnemyArea 18×4
- ✅ max_deployed_units 5→8
- ✅ AOEDamageAbility fix on EnemyUnit (use apply_damage instead of current_health)
- ✅ AoEHealAbility narrowing conversion fix (explicit int() casts)

### February 2026 (Session 4) — New Units, Resolution, Animation Prep
- ✅ Resolution increase: 640×360 → 960×540 viewport, 1920×1080 window
- ✅ 5 new ally units: Knight, Ranger, Rogue, Priest, Druid
- ✅ 5 new abilities: Iron Bastion, Power Shot, Deadly Focus, Holy Light, Nature's Wrath
- ✅ AoEHealAbility class (area heal with green flash)
- ✅ AnimatedSprite2D preparation (sprite_frames property in UnitStats)
- ✅ Warrior's Endurance passive stacking fix (guard flag + stats order)
- ✅ Retaliation targeting (units fight back when attacked)
- ✅ Aggro range fixes (Bjorn 3→5, Y multiplier 0.75→1.0)

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

### July 2026 (Session 8) — Documentation Update
- ✅ Game Design Document updated with English translation, current implementation status, and accurate project information
- ✅ README updated to reflect Legion TD identity (not TFT), current unit roster, accurate technical specs, and development status
- ✅ TODO updated with current date and session log
- ✅ All documentation aligned with skill file guidelines (Godot Architect, Game Designer, Content Generator, QA Tester)
- ✅ Project structure analyzed and documented (8 ally units, 6 enemy types, 15 waves, 3 factions)

---
*Last Updated: July 2026 (Session 8)*
