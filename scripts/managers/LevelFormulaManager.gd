class_name LevelFormulaManager
extends RefCounted


static func calculate_stats_from_base(strength: int, agility: int, intelligence: int) -> Dictionary:
	# Formulas are copied from the "Формулы лвлапа" document.
	return {
		"max_health": 15.0 + strength * 7.5,
		"armor": 2.5 + strength * 1.6,
		"heavy_weapon_damage": 6.0 + strength * 1.25,
		"light_weapon_damage": 5.0 + agility * 1.1,
		"magic_damage": 5.0 + intelligence * 1.25,
		"speed": 4.0 + agility * 0.35,
		"dodge": 10.0 + agility * 2.5,
		"crit_chance": 3.0 + agility * 0.7,
		"accuracy": 25.0 + agility * 2.0,
		"fire_resistance": 5.0 + strength * 2.0,
		"stun_resistance": 5.0 + strength * 1.8,
		"stress_resistance": 5.0 + intelligence * 2.0,
		"poison_resistance": 5.0 + agility * 1.7,
		"bleed_resistance": 7.0 + strength * 1.6,
		"debuff_chance": 10.0 + intelligence * 2.1,
		"healing_power": intelligence * 1.5
	}


static func apply_base_stats_to_hero(hero: HeroData) -> void:
	var stats := calculate_stats_from_base(hero.strength, hero.agility, hero.intelligence)
	var should_refill_health := hero.current_health <= 0

	_apply_stats(hero, stats)

	if should_refill_health:
		hero.current_health = int(hero.max_health)


static func get_stat_growth_after_level_up(
	old_strength: int,
	old_agility: int,
	old_intelligence: int,
	new_strength: int,
	new_agility: int,
	new_intelligence: int
) -> Dictionary:
	var old_stats := calculate_stats_from_base(old_strength, old_agility, old_intelligence)
	var new_stats := calculate_stats_from_base(new_strength, new_agility, new_intelligence)
	var growth := {}

	for stat_name in new_stats.keys():
		growth[stat_name] = new_stats[stat_name] - old_stats[stat_name]

	return growth


static func level_up_strength(hero: HeroData) -> void:
	_level_up_base_stat(hero, "strength")


static func level_up_agility(hero: HeroData) -> void:
	_level_up_base_stat(hero, "agility")


static func level_up_intelligence(hero: HeroData) -> void:
	_level_up_base_stat(hero, "intelligence")


static func _level_up_base_stat(hero: HeroData, stat_name: String) -> void:
	# Level-up growth is calculated as the difference between new and old formula values.
	var old_strength := hero.strength
	var old_agility := hero.agility
	var old_intelligence := hero.intelligence

	match stat_name:
		"strength":
			hero.strength += 1
		"agility":
			hero.agility += 1
		"intelligence":
			hero.intelligence += 1

	hero.level += 1

	var growth := get_stat_growth_after_level_up(
		old_strength,
		old_agility,
		old_intelligence,
		hero.strength,
		hero.agility,
		hero.intelligence
	)
	var new_stats := calculate_stats_from_base(hero.strength, hero.agility, hero.intelligence)

	_apply_stats(hero, new_stats)
	hero.current_health += int(growth["max_health"])


static func _apply_stats(hero: HeroData, stats: Dictionary) -> void:
	hero.max_health = stats["max_health"]
	hero.armor = stats["armor"]
	hero.heavy_weapon_damage = stats["heavy_weapon_damage"]
	hero.light_weapon_damage = stats["light_weapon_damage"]
	hero.magic_damage = stats["magic_damage"]
	hero.speed = stats["speed"]
	hero.dodge = stats["dodge"]
	hero.crit_chance = stats["crit_chance"]
	hero.accuracy = stats["accuracy"]
	hero.fire_resistance = stats["fire_resistance"]
	hero.stun_resistance = stats["stun_resistance"]
	hero.stress_resistance = stats["stress_resistance"]
	hero.poison_resistance = stats["poison_resistance"]
	hero.bleed_resistance = stats["bleed_resistance"]
	hero.debuff_chance = stats["debuff_chance"]
	hero.healing_power = stats["healing_power"]
