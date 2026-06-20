class_name UnitStatsPanel
extends PanelContainer

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var mana_label: Label = $VBoxContainer/ManaLabel
@onready var attack_label: Label = $VBoxContainer/AttackLabel
@onready var armor_label: Label = $VBoxContainer/ArmorLabel
@onready var magic_resist_label: Label = $VBoxContainer/MagicResistLabel
@onready var attack_speed_label: Label = $VBoxContainer/AttackSpeedLabel

var unit: Unit


func _ready() -> void:
	attack_label.visible = false
	armor_label.visible = false
	magic_resist_label.visible = false
	attack_speed_label.visible = false
	tooltip_text = ""

func set_unit(new_unit: Unit) -> void:
	if unit:
		disconnect_signals()
	
	unit = new_unit
	if unit:
		connect_signals()
		update_stats()
	else:
		tooltip_text = ""

func connect_signals() -> void:
	if unit.health_changed.is_connected(update_stats):
		return
	unit.health_changed.connect(update_stats)
	unit.mana_changed.connect(update_stats)

func disconnect_signals() -> void:
	if unit.health_changed.is_connected(update_stats):
		unit.health_changed.disconnect(update_stats)
	if unit.mana_changed.is_connected(update_stats):
		unit.mana_changed.disconnect(update_stats)

func update_stats(_new_value: int = -1) -> void:
	if not unit or not unit.stats:
		tooltip_text = ""
		return
	
	name_label.text = unit.stats.name
	health_label.text = "HP: %d/%d" % [unit.current_health, unit.stats.max_health]
	mana_label.text = "MP: %d/%d" % [unit.current_mana, unit.stats.max_mana]
	attack_label.text = "ATK: %d" % unit.stats.attack_damage
	armor_label.text = "AR: %d" % unit.stats.armor
	magic_resist_label.text = "MR: %d" % unit.stats.magic_resist
	attack_speed_label.text = "SPD: %.1f" % unit.stats.attack_speed
	tooltip_text = _build_tooltip()


func _build_tooltip() -> String:
	if not unit or not unit.stats:
		return ""

	var lines: Array[String] = []
	var title := unit.stats.name
	if unit.stats.is_king:
		title += " (King)"
	lines.append(title)
	lines.append("Team: %s" % _team_name(unit.stats.team))
	if unit.stats.is_king:
		lines.append("King unit: if it dies, the run ends.")
	lines.append("Health: %d/%d" % [unit.current_health, unit.stats.max_health])
	lines.append("Mana: %d/%d" % [unit.current_mana, unit.stats.max_mana])
	lines.append("Attack: %d" % unit.stats.attack_damage)
	lines.append("Ability Power: %d" % unit.stats.ability_power)
	lines.append("Armor: %d" % unit.stats.armor)
	lines.append("Magic Resist: %d" % unit.stats.magic_resist)
	lines.append("Attack Speed: %.1f" % unit.stats.attack_speed)
	if unit.stats.faction != UnitStats.Faction.NONE:
		lines.append("Faction: %s" % _faction_name(unit.stats.faction))
	return "\n".join(lines)


func _team_name(team: UnitStats.Team) -> String:
	match team:
		UnitStats.Team.PLAYER: return "Player"
		UnitStats.Team.ENEMY: return "Enemy"
	return "Unknown"


func _faction_name(faction: UnitStats.Faction) -> String:
	match faction:
		UnitStats.Faction.WARRIOR: return "Warrior"
		UnitStats.Faction.MYSTIC: return "Mystic"
		UnitStats.Faction.WARDEN: return "Warden"
	return "None"
