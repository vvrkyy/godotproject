class_name HeroData
extends Resource

@export var hero_id: String = ""
@export var hero_name: String = "Новый герой"
@export var level: int = 1
@export var current_exp: int = 0

@export var current_health: int = 0
@export var max_health: float = 0.0
@export var armor: float = 0.0
@export var heavy_weapon_damage: float = 0.0
@export var light_weapon_damage: float = 0.0
@export var magic_damage: float = 0.0
@export var speed: float = 0.0
@export var dodge: float = 0.0
@export var crit_chance: float = 0.0
@export var accuracy: float = 0.0
@export var fire_resistance: float = 0.0
@export var stun_resistance: float = 0.0
@export var stress_resistance: float = 0.0
@export var poison_resistance: float = 0.0
@export var bleed_resistance: float = 0.0
@export var debuff_chance: float = 0.0
@export var healing_power: float = 0.0

@export var strength: int = 1
@export var agility: int = 1
@export var intelligence: int = 1

@export var mental_state: String = "Стабильное"
@export var passive_skill: String = "Нет пассивного умения"
@export var ability_slots: Array[String] = ["", "", "", ""]
@export var item_slots: Dictionary = {
	"hand_1": null,
	"hand_2": null,
	"accessory_1": null,
	"accessory_2": null
}
@export var traits: Array[String] = []


func ensure_id() -> void:
	# GameState uses this id to avoid hiring the same hero twice.
	if hero_id.is_empty():
		hero_id = "%s_%d" % [hero_name.to_snake_case(), Time.get_ticks_usec()]
