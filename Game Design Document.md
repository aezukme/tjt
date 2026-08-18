Da, i zapravo bih ti preporučio da to uradiš sada, dok je projekat još relativno mali.

Na osnovu README-a i TODO-a koje si okačio, već postoji dovoljno informacija za **v1 GDD (Game Design Document)**.

Po mom iskustvu, najveći problem indie projekata nije kod nego što posle 3-6 meseci zaboraviš:

* šta je originalna vizija,
* šta je "must-have",
* šta je "nice-to-have",
* zašto je neka odluka doneta,
* šta čini igru drugačijom od konkurencije.

Zbog toga bih za TJT napravio dokument od 15-20 strana sa sledećom strukturom:

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

Ovo je najvažniji deo GDD-a.

### Pillar 1 — Strategy Over Reflexes

Pobednik treba da bude pametniji, ne brži.

### Pillar 2 — Economy Matters

Čuvanje golda mora biti jednako važno kao trošenje golda.

### Pillar 3 — Positioning Wins Games

Raspored jedinica mora biti važniji od čistog DPS-a.

### Pillar 4 — Predictable, Learnable Waves

Igrač treba da uči wave obrasce.

### Pillar 5 — Multiplayer Fairness

Nikakav RNG ne sme odlučivati partiju.

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

### Early Game

Wave 1-5

Fokus:

* osnovna ekonomija
* osnovni frontline

### Mid Game

Wave 6-10

Fokus:

* sinergije
* counter-buildovi

### Late Game

Wave 11-15

Fokus:

* optimizacija
* leak management
* king pressure

---

# 5. Economy

## Gold

Koristi se za:

* kupovinu jedinica
* unapređenja
* buduće sisteme

## Income

Dobija se svake runde.

Formula:

```text
Base Income
+ Bonus Income
+ Interest
```

## Interest

Primer:

```text
10 saved gold = +1 income
20 saved gold = +2 income
30 saved gold = +3 income
```

Cap:

```text
+10 income
```

---

# 6. King System

King predstavlja živote igrača.

Karakteristike:

* ne regeneriše HP
* šteta je trajna
* smrt znači poraz

King mora biti prikazan u HUD-u tokom cele partije.

---

# 7. Leak System

Kad neprijatelj prođe odbranu:

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

### Warrior

3 Units:

```text
+20% Attack Damage
```

### Mystic

3 Units:

```text
+20% Ability Power
```

### Warden

2 Units:

```text
+15% Attack Speed
```

---

# 9. Unit Classes

### Tank

Primer:

* Bjorn
* Knight

### DPS

Primer:

* Ranger
* Rogue
* Mage

### Support

Primer:

* Sage
* Priest

### Specialist

Primer:

* Druid

---

# 10. Wave Design

## Wave Categories

### Swarm

Mnogo slabih neprijatelja.

### Tank

Malo jakih neprijatelja.

### Mixed

Kombinacija.

### Boss

Veliki test builda.

---

# 11. Multiplayer Architecture

### Authority

Server authoritative.

### Clients

Vizuelna reprezentacija.

### Sync

Sinhronizovati:

* kupovinu
* prodaju
* postavljanje
* start wave
* economy

Ne sinhronizovati:

* čiste vizuelne efekte

---

# 12. Content Roadmap

## Milestone 1

Core Gameplay

Status:

90%

## Milestone 2

Economy Complete

Status:

40%

## Milestone 3

Multiplayer Foundation

Status:

10%

## Milestone 4

Beta

Status:

0%

---

# 13. Technical Architecture

### Managers

* BattleManager
* WaveManager
* SynergyManager

### Components

* UnitAI
* UnitAnimator
* UnitVisuals

### Data

* UnitStats
* WaveConfig
* Ability Resources

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

Iskreno, ovo bih smatrao obaveznim pre nego što kreneš u multiplayer, jer ćeš kasnije svaku novu ideju moći da proveriš pitanjem:

> "Da li je ovo u skladu sa GDD-om?"

To sprečava da projekat vremenom postane mešavina Legion TD-a, TFT-a, RPG-a i tower defense-a bez jasnog identiteta.
