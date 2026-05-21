extends Node

var hired_heroes: Array[HeroData] = []


func hire_hero(hero: HeroData) -> bool:
	hero.ensure_id()

	# The same recruit should not be added twice.
	if is_hero_hired(hero):
		return false

	hired_heroes.append(hero)
	return true


func get_hired_heroes() -> Array[HeroData]:
	return hired_heroes


func is_hero_hired(hero: HeroData) -> bool:
	hero.ensure_id()

	for hired_hero in hired_heroes:
		hired_hero.ensure_id()

		if not hero.hero_id.is_empty() and hired_hero.hero_id == hero.hero_id:
			return true

		if hired_hero.hero_name == hero.hero_name:
			return true

	return false
