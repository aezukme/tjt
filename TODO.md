# TODO List - TJT Game Development

## 🔥 High Priority

### Ability System ✅ COMPLETED
- [x] Implement ability casting mechanism when mana is full
- [x] Create base Ability class/resource
- [x] Create Passive Ability system (stat bonuses)
- [x] Visual effects for ability activation (projectile system)
- [x] Cooldown system for abilities
- [x] Create sample abilities (fireball, heal, AOE damage, mending bolt)
- [x] Ability targeting system (self, enemy, area)
- [x] Ability range system
- [x] Mana consumption on ability use
- **Implemented:**
  - Base `Ability` resource class with targeting, cooldown, range
  - `PassiveAbility` for permanent stat bonuses
  - Fireball (single target, 100 dmg, 200 range, projectile visual)
  - Mending Bolt (heal ally 60 HP or damage enemy 50 — dual mode)
  - Heal (self heal, 30 HP)
  - AOE Damage (all enemies, 25 dmg)
  - Warrior's Endurance passive (+20% health regen for Bjorn)
  - Projectile scene with smooth movement and hit detection

### Wave System ✅ COMPLETED
- [x] Enemy wave spawner component (WaveManager)
- [x] Wave configuration (WaveConfig resources with enemy groups)
- [x] Progressive difficulty scaling (+5% per wave)
- [x] Boss rounds (configurable interval)
- [x] Wave countdown timer (30s between waves, skippable)
- [x] Between-wave preparation phase with position restore & stat reset
- [x] Victory/defeat conditions (all waves cleared / all allies dead)
- **Implemented:**
  - `WaveManager` with 4 configurable waves (wave_1 through wave_5_boss)
  - Spiral-pattern enemy spawning from grid center
  - Gold + XP rewards per wave
  - 30-second prep timer between waves (skip via button)
  - Ally positions saved before battle, restored after
  - Full stat reset (HP, mana, cooldowns, AI state) between rounds

### Unit Selection Panel 🔧 IN PROGRESS
- [ ] Bottom panel with available ally unit cards
- [ ] Click to add unit to arena (place at first available tile)
- [ ] Click to remove unit from arena
- [ ] Show unit stats on card (name, HP, ATK, ability)
- [ ] Limit max units on field
- [ ] Later: integrate with gold cost system

### Visual Polish
- [x] Damage numbers (floating text above units)
- [x] Projectile visuals for ranged abilities
- [ ] Particle effects for attacks
  - [ ] Melee hit effects
  - [x] Ranged projectile (fireball implemented)
  - [ ] Critical hit effects
- [ ] Unit death animations
- [ ] Screen shake on critical hits/explosions
- [ ] Attack animations (sprite flipping/rotation)
- [ ] Ability cast animations
- **Implemented:**
  - Damage number system with float up + fade out
  - Scale based on damage amount
  - Random horizontal spread
  - Fireball projectile with smooth flight

## 🎯 Medium Priority

### Unit Traits/Synergies (TFT-style)
- [ ] Define trait types (Warrior, Mage, Healer, Ranger, Beast, Undead, etc.)
- [ ] Add trait property to UnitStats
- [ ] Trait counter UI panel
- [ ] Synergy bonus system
  - [ ] 2/4/6 of same trait = bonus
  - [ ] Different bonus types (stats, abilities, effects)
- [ ] Visual indicators for active synergies
- [ ] Trait descriptions and tooltips

### XP & Leveling System
- [ ] Player level tracking
- [ ] XP gain from winning rounds
- [ ] Level-up rewards
- [ ] Unlock additional unit slots based on level
- [ ] Better shop odds at higher levels
- [ ] Interest system (gold per 10 saved)
- [ ] Player level display UI

### Combat Improvements
- [ ] Frontline/Backline positioning logic
- [ ] Tank aggro system (enemies prefer attacking tanks)
- [ ] Ranged units prefer backline targets
- [ ] Attack priority system (low HP, high threat, etc.)
- [ ] Critical hit system
- [ ] Dodge/Evasion mechanic
- [ ] Status effects (stun, slow, poison, burn, freeze)
- [ ] Armor/Magic Resist tooltips showing % reduction

### Shop Improvements
- [ ] Lock/freeze shop (prevent auto-refresh)
- [ ] Unit reroll cost scaling with level
- [ ] Highlight units you can afford
- [ ] Show unit count remaining in pool
- [ ] Shift-click to buy and auto-place unit
- [ ] Undo last purchase button

## 📦 Low Priority / Nice to Have

### Items & Equipment
- [ ] Item drop system during combat
- [ ] Item inventory UI
- [ ] Drag items onto units to equip
- [ ] Item stat bonuses
- [ ] Item tier system (common, rare, epic, legendary)
- [ ] Item combining (2 items → 1 upgraded item)
- [ ] Special item effects (lifesteal, splash damage, etc.)

### Advanced AI
- [ ] AI difficulty levels
- [ ] Better pathfinding around allies
- [ ] Formation keeping (units stick together)
- [ ] Focus fire (multiple units target same enemy)
- [ ] Retreat logic when low HP
- [ ] Ability usage AI (smart spell casting)

### UI/UX Improvements
- [ ] Unit tooltip on hover (show all stats)
- [ ] Combat log/battle history
- [ ] Minimap for larger arenas
- [ ] Settings menu (volume, graphics, keybinds)
- [ ] Tutorial/Help system
- [ ] Unit preview in shop (show abilities)
- [ ] Drag unit to reposition during prep phase

### Meta Progression
- [ ] Save/Load system
- [ ] High score tracking
- [ ] Player statistics (games played, wins, units bought, etc.)
- [ ] Achievements system
- [ ] Daily challenges
- [ ] Unlockable unit skins

### Audio
- [ ] Battle music integration
- [ ] Sound effects for:
  - [ ] Unit attacks
  - [ ] Ability casts
  - [ ] Gold spending
  - [ ] Unit combining
  - [ ] Victory/defeat
  - [ ] UI clicks
- [ ] Volume sliders for music/SFX

### Balance & Content
- [ ] Add more unit types (need 15-20 for variety)
- [ ] Balance pass on existing units
- [ ] Add more abilities (need 10+ unique abilities)
- [ ] Different arena layouts
- [ ] Environmental hazards

### Performance & Polish
- [ ] Object pooling for projectiles/effects
- [ ] Optimize pathfinding (cache results, update less frequently)
- [ ] Particle system optimization
- [ ] Loading screen
- [ ] Transition animations between phases

## 🐛 Bug Fixes / Technical Debt
- [x] Test mana_bar_filled signal usage (working!)
- [x] Fixed mana regeneration system (battle state check)
- [x] Fixed BattleManager type casting issues
- [x] Verify all .tres files have health_regen values set
- [x] Fixed Lambda capture / emit_signalp errors (unit_visuals.gd)
- [x] Fixed AI spam during PREPARATION phase (battle state guard)
- [x] Fixed remaining_enemies going to -1 (double-decrement guard)
- [ ] Fix emit_signalp warnings on timer callbacks (static lambda issue)
- [ ] Remove duplicate mana_changed.emit() in _set_current_mana
- [ ] Consistent naming conventions (snake_case vs PascalCase)
- [ ] Fix sage_ally.tres UID warning (uid://dh3al0rharm01)

## 🎨 Asset Needs
- [ ] More unit sprites (currently using 32rogues)
- [ ] Ability/spell effect sprites
- [ ] Item icons
- [ ] UI elements (buttons, panels, borders)
- [ ] Background art for arena
- [ ] Victory/defeat screen graphics

---

## Quick Wins (Easy to implement, high impact)
1. ✅ **Damage numbers** - immediate visual feedback - DONE!
2. ✅ **Wave system** - progressive enemy spawning - DONE!
3. ✅ **Wave counter UI** - player knows progress - DONE!
4. ⚡ **Unit selection panel** - add/remove units before battle - IN PROGRESS
5. ⚡ Victory/defeat screen - game flow completion
6. ⚡ Unit tooltip on hover - better info display
7. ⚡ Attack sound effects - more satisfying combat

## Session Log

### February 2026 — Battle System & Wave Overhaul
- ✅ Wave system: 4 waves with WaveConfig resources, spiral spawning, difficulty scaling
- ✅ Between-wave flow: 30s prep timer, position save/restore, stat reset
- ✅ Sage healer unit with Mending Bolt (heal allies / damage enemies)
- ✅ HealOrHarmAbility class for dual-mode abilities
- ✅ Fixed emit_signalp callback type errors (lambda Callable pattern)
- ✅ Fixed AI spam during non-BATTLE states
- ✅ Fixed remaining_enemies going negative
- ✅ UI: Arial system font, compact stats panels, wave display

### November 2025 — Ability System & Combat
- ✅ Damage Number System (float up + fade out)
- ✅ Complete Ability System (Fireball, Heal, AOE, Passive)
- ✅ Projectile System (smooth flight, hit detection)
- ✅ Float-based health/mana regeneration
- ✅ Bug fixes (mana regen, BattleManager casting, console spam)

---
*Last Updated: February 2026*
