# TJT — Unit & Ability Blueprints

> Design reference derived from the *Legion TD Mega Book 3.41* tower catalog
> (`reference/legion_td_mega_book.md`), adapted to TJT's rules: permadeath,
> deck-building, no RNG (GDD Pillar 6), 7 tiers instead of Legion's 6.
>
> **Legend:** ✅ implemented in engine · 🧩 data-only (script exists, no unit uses it yet) ·
> 📐 blueprint (needs new engine support — noted per entry)

---

## 1. Tier System

Legion TD tiers are the tower's "level": tier 1 is the cheapest/weakest, tier 6 the most
expensive. Every tower can be upgraded once or twice, and the upgrade **keeps the tier of
its base**. TJT follows the same rule and adds **tier 7 — Champions**: one-per-deck
signature units (Legion has no equivalent; think of them as our "hero towers").

| Tier | Role in TJT | Gold (current) | Rarity band | HP band (base) | Legion analog |
|------|-------------|----------------|-------------|----------------|---------------|
| 1 | Cheap frontline filler, early waves | 1 | Common | 300–500 | Orc Warrior, Peasant, Ent |
| 2 | Early DPS / utility | 2 | Common | 300–450 | Ranger, Archer, Orc Warlock |
| 3 | Core tank / core DPS / first support | 3 | Uncommon | 350–650 | Footman, Sentry, Captain |
| 4 | Supports, auras, specialists | 4 | Uncommon | 350–750 | Priest, Medicine Man, Mermaid |
| 5 | Heavy DPS / heavy tank | 5 | Rare | 500–1100 | Knight, Druid, Cyborg |
| 6 | Mid/late anchors, big abilities | 7 | Rare | 1200–1600 | Moon Guard, Minotaur, Sea Giant |
| 7 | **Champion** — one per deck, match-defining | 10 | Legendary | 1800–2500 | *(none — TJT original)* |

Gold values are placeholders until the economy milestone (GDD §14); the **ratios** are what
matter: each tier roughly doubles the value of the previous one, like Legion's 15 → 35 → 70 →
130 → 220 → 340 curve.

### Upgrade pricing rule
The upgraded unit's `gold_cost` is its **total** value. Upgrade price = difference. Selling
refunds the full total (see `UnitStats.get_upgrade_cost()`).

### Synergy rule
Base + upgrade share a `unit_line`, so Knight and Cavalier count as **one** unique Warrior.

---

## 2. Current Roster (after rework)

| Unit | Tier | Cost | Faction | Role | Active | Passive | Legion source |
|------|------|------|---------|------|--------|---------|---------------|
| **Bjorn** | 1 | 1 | Warrior | Melee bruiser | — | ✅ **Berserk** (+20/40/60% AS below 60/40/20% HP) | Wolverine's Berserk |
| **Ranger** | 2 | 2 | Warden | Long-range DPS | ✅ Power Shot (120 dmg projectile) | ✅ **Precision** (every 3rd shot ×1.6) | Ranger → Meliai |
| **Mage** | 2 | 2 | Mystic | Ranged caster | ✅ Fireball (100 dmg projectile) | ✅ **Magic Missile** (+15 magical per attack) | Sentry's Magic Missile |
| **Knight** | 3 | 3 | Warrior | Tank | — | ✅ Iron Bastion (+5 armor) | Footman / Knight |
| ↳ **Cavalier** | 3 | 6 (3+3) | Warrior | Heavy tank | — | ✅ Harden Armor (−6 dmg per hit, min 1) | Cavalier |
| **Rogue** | 3 | 3 | Warrior | Melee burst | — | ✅ **Vital Slice** (every 4th hit ×2) | Krogoth's Vital Slice |
| **Sage** | 3 | 3 | Mystic | Healer | ✅ **Healing Wave** (90, bounces 4×, −25%) | — | Medicine Man |
| **Priest** | 4 | 4 | Warden | Group healer | ✅ Holy Light (50 HP to 4 most wounded, 5 s CD) | — | Yggdrasil's Sacred Blessing |
| **Druid** | 5 | 5 | Mystic | AoE caster | ✅ **Wrath of Nature** (100 magical, bounces 5×, −25%) | — | Druid (exact) |
| **King** | — | — | — | Player's life | — | — | The King |

Chance-based Legion effects were converted to deterministic counters
("33% chance for 160%" → "every 3rd attack 160%") so average DPS is preserved
while the outcome of a fight never depends on a roll.

---

## 3. Ability Catalog

### 3.1 Passive framework (`PassiveAbility`) — ✅ implemented

Hooks called by the engine:

| Hook | Called from | Used by |
|------|-------------|---------|
| `apply(unit)` | `Unit._connect_stats_signals` | stat passives, Berserk base capture |
| `modify_outgoing_damage(unit, dmg)` | `CombatResolver` (before hit) | NTH_ATTACK_MULTIPLIER |
| `modify_incoming_damage(dmg)` | `Unit.apply_damage` (after armor) | DAMAGE_REDUCTION |
| `on_attack_hit(unit, target, dealt)` | `CombatResolver` (after hit) | MAGIC_MISSILE, LIFESTEAL, ARMOR_SHRED, SPLASH, MULTISHOT |
| `on_health_changed(unit)` | `Unit.health_changed` signal | BERSERK |

Only **basic attacks** (melee strike or basic-attack arrow) run through `CombatResolver`;
ability damage never triggers on-hit passives.

| PassiveType | .tres | Status | Description | Legion source |
|-------------|-------|--------|-------------|---------------|
| HEALTH_REGEN_BONUS | `warriors_endurance.tres` | ✅ (unused now) | +20% HP regen | Bone Warrior's Frenzy |
| DAMAGE_BONUS | `deadly_focus.tres` | ✅ (unused now) | +25% ATK | Greymane's Battle Cry (permanent half) |
| ARMOR_BONUS | `iron_bastion.tres` | ✅ Knight | +5 armor | Azure Armor / Reassurance (self) |
| SPEED_BONUS | — | ✅ engine | +X% attack speed | Chemical Rage (permanent variant) |
| MAX_HEALTH_BONUS | — | ✅ engine | +X% max HP | Inject Steroids (+20% HP) |
| DAMAGE_REDUCTION | `harden_armor.tres` | ✅ Cavalier | −6 flat per hit, min 1 | Harden Armor / Natural Armor |
| NTH_ATTACK_MULTIPLIER | `precision.tres`, `vital_slice.tres` | ✅ Ranger, Rogue | every Nth attack ×value | Precision, Vital Slice, Coup de Grace |
| MAGIC_MISSILE | `magic_missile.tres` | ✅ Mage | +15 magical per attack | Sentry, Flaming Arrows |
| LIFESTEAL | `frenzy_lifesteal.tres` | 🧩 | heal 15% of damage dealt | Frenzy Ghoul, The Butcher |
| ARMOR_SHRED | `corruption.tres` | 🧩 | −4 armor per hit, permanent, floor 0 | Corruption, Faerie Fire |
| SPLASH | `circle_splash.tres` | 🧩 | 50% dmg to enemies within 48 px of target | Circle Splash, Meat Wagon |
| MULTISHOT | `burst_shot.tres` | 🧩 | 50% dmg to 2 nearest other enemies | Burst Shot, Multishot, Moon Glaive |
| BERSERK | `berserk.tres` | ✅ Bjorn | AS scales with missing HP | Wolverine's Berserk |

### 3.2 Active abilities (`Ability` subclasses) — ✅ implemented

| Script | .tres | Description | Legion source |
|--------|-------|-------------|---------------|
| `FireballAbility` | `fireball.tres`, `power_shot.tres` | single-target projectile | Zeus' Power Surge (as a nuke) |
| `HealOrHarmAbility` | `mending_bolt.tres` (unused now) | heal lowest ally or damage nearest enemy | — |
| `HealAbility` | `heal.tres` | self / single heal | Priest's Heal |
| `AOEDamageAbility` (+`max_targets`) | `arcane_explosion.tres`, `natures_wrath.tres` (unused now) | damage all / N nearest enemies | Silent Scream (3), Fan of Knives (5), Tremor |
| `AoEHealAbility` (+`max_targets`) | `holy_light.tres` | heal all / N most wounded | Sacred Blessing (4), Water of Life (6) |
| `ChainDamageAbility` | `wrath_of_nature.tres` | bounce damage with falloff | Wrath of Nature, Storm Hammers |
| `ChainHealAbility` | `healing_wave.tres` | bounce heal with falloff | Healing Wave |

### 3.3 Abilities that need new engine systems — 📐 blueprints

| Ability | Effect | Needed system | Legion source |
|---------|--------|---------------|---------------|
| **Stun** (Storm Bolt, Fissure, Cluster Rockets) | target can't move/attack for N s | `UnitAI.stun(duration)` — skip `_process` while `_stun_timer > 0`; deterministic via mana cast, never on-hit chance | Thrall, Bigfoot, Clockwreck |
| **Attack-speed slow** (Cripple, Tremor, Traumatize) | −X% AS for N s | `StatusEffect` component: timed multiplier on `stats.attack_speed`, restored on expiry | Orc Warlock, Minotaur, Mercurial |
| **Move-speed slow** (Frost Aura, Chrono Trigger, Biotoxin) | −X% move speed | expose `movement_speed` on `UnitAI` to status effects | Polar Bear, Tree of Time, Defiler |
| **Poison / DoT** (Envenom, Haunting, Breath of Frost) | X dmg/s for N s | tick timer in `StatusEffect`; Envenom rule "can't kill, stops at 1 HP" is a nice permadeath-friendly variant | Harpy, Dark Priest, Young Frost Dragon |
| **Auras** (Leadership +7% dmg, Healing Aura +5 HP/s, Reassurance +3 armor, Telescope +8% ranged dmg, Adrenaline Rush +8% AS, Sickness −5% enemy dmg) | passive buff to allies in radius / all | `AuraManager` (mirror of `SynergyManager`): re-evaluate on placement/removal, store base values in node meta, stack rule per aura | Captain, Witch Doctor, Goliath, Flying Machine, Troll Champion, Apparition |
| **Guardian Spirit** | adjacent allies take −33% damage during the wave | aura + `modify_incoming_damage` multiplier on targets | Oracle |
| **Mana Shield** (Energy Shield, Ghost Essence) | mana absorbs damage (1 mana = 4 dmg) | `modify_incoming_damage` variant that spends `current_mana` | Seer of Darkness, Meridian |
| **Mana Burst / Power Surge** | +60 dmg on attack for 10 mana | on-hit passive that spends mana instead of counting attacks | Disciple, Zeus |
| **Amplify Magic** | +4%/s mana regen to all allies | aura on `mana_regen` | Messiah |
| **Battle Cry / Enchant Fire** | +5 armor & +20% dmg for 25 s once engaged | `SelfBuffAbility` (timed stat buff, reverts) | Greymane, Sword Mage |
| **Chemical Rage** | +100% AS for the whole wave | `SelfBuffAbility` with wave-length duration | Alchemist |
| **Summons** (Raise Dead, Invoke Inferno, Mitosis, Goblin Driver) | spawn temporary allied unit | `UnitSpawner` support for temp units that die at wave end (must not count as permadeath) | Necromancer, Lord of Death, Hydra, Steamroller |
| **Mirage** | illusion copy (50% dmg, 200% dmg taken) | summon system + stat multipliers | Maverick |
| **Feast** | heal 25 HP every 5 attacks | trivial: NTH counter + heal — add `PassiveType.FEAST` | Fangtooth |
| **Evasion** | dodge attacks | ❌ rejected — pure RNG; use DAMAGE_REDUCTION instead | Wandigoo, Sprite |
| **Finishing Blow** | 5% chance to one-shot | ❌ rejected — RNG; deterministic alternative: "execute enemies below 10% HP" | Wolverine |
| **Delicacy** | sells for 90% | ❌ not needed — TJT already refunds 100% | Bottom Feeder |

---

## 4. Upgrade Trees for the Current Roster

Format: **Base (T) → Upgrade** · stats (HP / ATK / AS / AR / MR) · ability · Legion source.
All upgrades keep the base tier and `unit_line`.

### Bjorn (T1, Warrior)
- **→ Bjorn Blood-Axe** · 900 / 80 / 0.8 / 8 / 20 · cost 1+2 · passive *Berserk* (stronger: +30/60/90%) + *Life Steal* 15% 🧩 → needs a second passive slot **or** a combined `BERSERK_LIFESTEAL` type. · *Wolverine + Frenzy Ghoul*
- **→ Bjorn Slavemaster** *(alt, economy)* · 770 / 65 / 0.7 / 6 / 20 · +3 gold at wave end if alive 📐 (needs wave-end hook) · *Slavemaster*

### Ranger (T2, Warden)
- **→ Meliai** · 335 / 42 / 1.0 / 2 / 15 · range 5 · *Precision* + **Mark Target** (ARMOR_SHRED −3) 🧩 needs second passive slot · *Meliai*
- **→ Elite Archer** *(alt)* · 650 / 30 / 1.1 / 3 / 15 · **Multishot** (`burst_shot.tres`: 2 extra targets 50%) 🧩 ready · *Elite Archer — "best single unit in game"*

### Mage (T2, Mystic)
- **→ Blood Warlock** · 660 / 60 / 0.8 / 2 / 35 · Fireball 150 + **Corruption** (`corruption.tres`) 🧩 ready · *Blood Orc Warlock*
- **→ Pyromancer** *(alt)* · 500 / 45 / 0.9 / 3 / 30 · **Breath of Fire**: AoE 60 + burn 5/s for 6 s 📐 needs DoT · *Young Frost Dragon (fire flavor)*

### Knight (T3, Warrior) — ✅ Cavalier implemented
- **→ Cavalier** ✅ · 1100 / 65 / 0.7 / 15 / 20 · *Harden Armor*
- **→ Guard** *(alt)* · 1150 / 50 / 0.9 / 12 / 15 · **Defend**: −15% damage from ranged attackers 📐 needs attacker-range check in `modify_incoming_damage` · *Guard*

### Rogue (T3, Warrior)
- **→ Nightblade** · 520 / 90 / 1.1 / 4 / 15 · **Fatality**: every 5th hit ×3 (NTH, value 3, interval 5) ✅ engine-ready · *Nightmare / Doppelganger*
- **→ Shadow Assassin** *(alt)* · 450 / 80 / 1.0 / 4 / 20 · **Execute**: hits vs enemies below 15% HP deal ×4 📐 needs HP-threshold multiplier · *Finishing Blow (deterministic)*

### Sage (T3, Mystic)
- **→ Oracle** · 600 / 40 / 0.6 / 3 / 40 · Healing Wave 120 + **Guardian Spirit** (adjacent allies −33% dmg) 📐 aura · *Oracle*
- **→ Witch Doctor** *(alt)* · 550 / 35 / 0.7 / 3 / 35 · **Healing Aura**: +5 HP/s to all allies 📐 aura · *Young Witch Doctor*

### Priest (T4, Warden)
- **→ High Priest** · 700 / 30 / 0.6 / 3 / 45 · Holy Light 80 to 6 targets + **Greater Heal** 300 single (second active) 📐 needs 2nd ability slot **or** merge into one smart heal · *High Priest*
- **→ Highborne** *(alt)* · 930 / 60 / 0.8 / 4 / 40 · **Sphere**: +5 armor to the most-attacked ally 📐 aura-lite · *Highbourne*

### Druid (T5, Mystic)
- **→ Ascendant** · 1450 / 80 / 0.8 / 4 / 35 · Wrath of Nature 150, bounces 6× + **Faerie Fire** (ARMOR_SHRED −6) 🧩 · *Ascendant — "insane tower, strong on every wave"*
- **→ Sword Mage** *(alt, melee)* · 1850 / 90 / 0.9 / 10 / 30 · range 1 · **Enchant Fire**: +60 magical per attack (MAGIC_MISSILE value 60) ✅ engine-ready · *Sword Mage*

---

## 5. New Unit Blueprints (fill the empty tiers)

Sprite slots still free on `asset/sprites/rogues.png` (5×5 grid, 32 px):
(0,0) (1,0) (4,0) (1,1) (2,1) (3,1) (0,2) (3,2) (0,3) (2,3) (3,3) (4,3) (1,4) (3,4) (4,4).

### Tier 1
| Unit | Faction | Stats | Ability | Source | Engine |
|------|---------|-------|---------|--------|--------|
| **Ent** | Mystic | 320 / 18 / 1.2 / 6 / 10, melee | → *Guardian*: **Entangle** (root + 10 dmg/s, 4 s) | Ent → Guardian | 📐 root/DoT |
| **Peasant** | Warrior | 280 / 22 / 1.0 / 3 / 5, melee | → *Militia*: plain stat upgrade | Peasant → Militia | ✅ |

### Tier 2
| Unit | Faction | Stats | Ability | Source | Engine |
|------|---------|-------|---------|--------|--------|
| **Frost Wolf** | Warden | 400 / 30 / 1.3 / 4 / 10, melee | **Bleeding**: below 30% HP attacks slow target AS 25% | Frost Wolf | 📐 slow |
| **Infantry** | Warden | 320 / 25 / 0.9 / 2 / 10, range 5 | → *Zeus*: **Power Surge** (+50 dmg every 10th attack — NTH ×3, interval 10) | Infantry → Zeus | ✅ |

### Tier 3
| Unit | Faction | Stats | Ability | Source | Engine |
|------|---------|-------|---------|--------|--------|
| **Phantom** | Mystic | 475 / 0 / — / 2 / 40, range 3 | no auto-attack; **Silent Scream** AoE 30 to 3 nearest, 2 s CD (`AOEDamageAbility`, max_targets 3) | Phantom → Hell Raiser (55) | ✅ (needs "no attack" flag: `attack_damage = 0` works today) |
| **Captain** | Warrior | 585 / 45 / 0.8 / 8 / 15, melee | **Leadership**: +7% dmg to all allies | Captain → Admiral (+12%) | 📐 aura |
| **Machine Turret** | Warden | 380 / 28 / 1.2 / 3 / 5, range 4 | **Burst Shot** (`burst_shot.tres`) | Machine Turret → Machine Robot | 🧩 ready |
| **Ghoul** | Warrior | 480 / 40 / 1.1 / 4 / 10, melee | **Life Steal** (`frenzy_lifesteal.tres`) | Ghoul → Frenzy Ghoul | 🧩 ready |

### Tier 4
| Unit | Faction | Stats | Ability | Source | Engine |
|------|---------|-------|---------|--------|--------|
| **Mermaid** | Warden | 505 / 45 / 1.0 / 3 / 25, range 3 | **Sphere**: +5 armor to one ally; → *Highborne* adds **Storm Geyser** (heal 10/s + 40 dmg to 3 enemies every 7 s, 15 s) | Mermaid → Highbourne | 📐 aura + summon-lite |
| **Polar Bear** | Warrior | 700 / 50 / 0.8 / 10 / 15, melee | **Frost Aura**: −40% enemy move speed nearby; → *Magnataur*: every 2nd hit ×1.4 (NTH) | Polar Bear → Magnataur | 📐 slow (aura) / ✅ crit |
| **Witch Doctor** | Mystic | 400 / 35 / 0.9 / 2 / 35, range 3 | **Healing Aura** +5 HP/s all allies; → *Elder* +10 HP/s | Young → Elder Witch Doctor | 📐 aura |
| **Overseer** | Mystic | 625 / 50 / 0.8 / 4 / 30, range 3 | **Blood Thirst**: all melee allies gain 8% lifesteal | Overseer → Keeper of Souls (16%) | 📐 aura |

### Tier 5
| Unit | Faction | Stats | Ability | Source | Engine |
|------|---------|-------|---------|--------|--------|
| **Cyborg** | Warrior | 1035 / 85 / 0.8 / 12 / 15, melee | → *Krogoth*: **Vital Slice** (every 4th ×2) | Cyborg → Krogoth | ✅ |
| **Apparition** | Mystic | 665 / 90 / 1.0 / 4 / 35, range 4 | **Sickness Aura**: −5% damage on all enemies; → *Gravekeeper* −10% | Apparition → Gravekeeper | 📐 enemy aura |
| **Komodo** | Warden | 880 / 65 / 0.9 / 8 / 20, melee | → *Trident*: **Concussion** every 5th hit ×2 + stun 1 s | Komodo → Trident | 📐 stun |
| **Nightmare** | Warrior | 995 / 30 / 2.5 / 5 / 15, melee | very fast; **Fatality** every 5th ×2 | Nightmare → Doppelganger (AS 4.0, ×3) | ✅ |

### Tier 6
| Unit | Faction | Stats | Ability | Source | Engine |
|------|---------|-------|---------|--------|--------|
| **Moon Guard** | Warden | 1350 / 85 / 1.0 / 12 / 20, melee | **Fan of Knives**: 60 dmg to 5 nearest (AOE max_targets 5); → *Warden*: **Coup de Grace** every 2nd hit ×2 | Moon Guard → Warden | ✅ |
| **Minotaur** | Warrior | 1415 / 140 / 0.8 / 14 / 15, melee | **Tremor**: 20 AoE + −10% AS 4 s; → *Bigfoot*: **Fissure** 75 AoE + stun 1 s | Minotaur → Bigfoot | 📐 slow/stun |
| **Sea Giant** | Warrior | 1380 / 125 / 1.0 / 12 / 20, melee | → *Hydra* (ranged): **Triple Attack** every 3rd hit strikes 3 (MULTISHOT 0.8, 2 extra) + **Mitosis** (3 Mini-Hydras on death) | Sea Giant → Hydra | 🧩 / 📐 summon |
| **Dragon Hawk** | Mystic | 1480 / 125 / 0.8 / 8 / 30, range 4 | → *Royal Griffin*: **Storm Hammers** (`ChainDamageAbility` 300, 2 bounces, 0.6) | Dragon Hawk → Royal Griffin | ✅ |
| **Yggdrasil** | Mystic | 1250 / 95 / 0.8 / 15 / 25, melee | **Sacred Blessing** (AoE heal 40, 4 targets, 5 s); → *Tree of Life* (6 targets, heals 150 on death) / *Tree of Knowledge* (200 AoE on death, 24% melee reflect) | Yggdrasil | ✅ / 📐 on-death, reflect |
| **Lord of Death** | Mystic | 845 / 40 / 1.9 / 6 / 30, range 3 | **Invoke Inferno**: summon Infernal 850 HP tank | Lord of Death → Hades | 📐 summon |

### Tier 7 — Champions (TJT original, one per deck)
Champions are the deck's identity card. Rules proposal: exactly one T7 per deck,
cannot be sent to the opponent in PvP, King aura interacts with them.

| Champion | Faction | Stats | Kit | Built from |
|----------|---------|-------|-----|------------|
| **Warchief Thrall** | Warrior | 2500 / 250 / 1.0 / 20 / 25, range 2 | **Storm Bolt** 300 dmg + 3 s stun (single, 8 s CD) · passive **Pulverize**: every 5th hit 30 AoE | Orc Warchief → Thrall · 📐 stun |
| **Fenix, Seer of Darkness** | Mystic | 1700 / 190 / 1.0 / 8 / 45, range 4 | **Energy Shield**: mana absorbs 4 dmg per point (350 mana) · **Focus Energy**: +1 dmg per 3 mana remaining | Seer of Darkness → Fenix · 📐 mana shield |
| **Doomsday Machine** | Warden | 3000 / 330 / 0.9 / 25 / 10, range 4 | **Siege Shell**: Circle Splash 50% · **Overclock**: +20% AS for the wave | Neotank → Doomsday Machine · 🧩 splash, 📐 buff |
| **Messiah** | Mystic | 1085 / 120 / 0.9 / 4 / 40, range 4 | **Amplify Magic**: all allies +4%/s of max mana as regen · Mana Burst +60 dmg / 10 mana | Disciple → Messiah · 📐 aura |
| **Goliath** | Warrior | 1665 / 260 / 0.6 / 22 / 20, melee | **Natural Armor**: −50 flat per hit (DAMAGE_REDUCTION) · **Reassurance**: +3 armor to adjacent allies | Halfbreed → Goliath · ✅ / 📐 aura |

---

## 6. Implementation Roadmap (engine work unlocked per step)

1. **StatusEffect component** (timed stat modifiers + DoT tick + stun flag on `UnitAI`)
   → unlocks Cripple, Tremor, Envenom, Storm Bolt, Fissure, Frost Nova, Battle Cry, Chemical Rage.
2. **AuraManager** (SynergyManager pattern: register/unregister, radius or global, stack rules)
   → unlocks Leadership, Healing Aura, Reassurance, Telescope, Adrenaline Rush, Sickness, Blood Thirst, Guardian Spirit, Amplify Magic.
3. **Second passive slot** (`passive_abilities: Array[PassiveAbility]`) → Meliai, Blood-Axe, Ascendant.
4. **Temporary summons** (spawner flag `is_summon`, freed at wave end, excluded from permadeath toasts and deployed count) → Raise Dead, Invoke Inferno, Mitosis, Goblin Driver, Storm Geyser.
5. **On-death triggers** (`PassiveAbility.on_death`) → Tree of Life / Knowledge, Mitosis.
6. **Upgrade choice popup** for branching upgrades (currently hotkey U takes `upgrades[0]`).
