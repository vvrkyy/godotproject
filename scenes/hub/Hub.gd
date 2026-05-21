extends Control

var available_heroes: Array[HeroData] = []
var rng := RandomNumberGenerator.new()

@onready var highlight_recruit: TextureRect = %HighlightRecruit
@onready var highlight_blacksmith: TextureRect = %HighlightBlacksmith
@onready var highlight_market: TextureRect = %HighlightMarket
@onready var highlight_hospital: TextureRect = %HighlightHospital
@onready var highlight_barracks: TextureRect = %HighlightBarracks
@onready var highlight_expedition: TextureRect = %HighlightExpedition

@onready var recruit_click_area: Button = %RecruitClickArea
@onready var blacksmith_click_area: Button = %BlacksmithClickArea
@onready var market_click_area: Button = %MarketClickArea
@onready var hospital_click_area: Button = %HospitalClickArea
@onready var barracks_click_area: Button = %BarracksClickArea
@onready var expedition_click_area: Button = %ExpeditionClickArea

@onready var recruit_panel: PanelContainer = %RecruitPanel
@onready var barracks_panel: PanelContainer = %BarracksPanel
@onready var recruit_list: VBoxContainer = %RecruitList
@onready var barracks_list: VBoxContainer = %BarracksList
@onready var info_message: Label = %InfoMessage
@onready var close_recruit_button: Button = %CloseRecruitButton
@onready var close_barracks_button: Button = %CloseBarracksButton
@onready var fade_rect: ColorRect = %FadeRect


func _ready() -> void:
	rng.randomize()
	hide_all_highlights()

	recruit_click_area.mouse_entered.connect(show_highlight.bind(highlight_recruit))
	recruit_click_area.mouse_exited.connect(hide_all_highlights)
	recruit_click_area.pressed.connect(_on_recruit_pressed)

	blacksmith_click_area.mouse_entered.connect(show_highlight.bind(highlight_blacksmith))
	blacksmith_click_area.mouse_exited.connect(hide_all_highlights)
	blacksmith_click_area.pressed.connect(_on_blacksmith_pressed)

	market_click_area.mouse_entered.connect(show_highlight.bind(highlight_market))
	market_click_area.mouse_exited.connect(hide_all_highlights)
	market_click_area.pressed.connect(_on_market_pressed)

	hospital_click_area.mouse_entered.connect(show_highlight.bind(highlight_hospital))
	hospital_click_area.mouse_exited.connect(hide_all_highlights)
	hospital_click_area.pressed.connect(_on_hospital_pressed)

	barracks_click_area.mouse_entered.connect(show_highlight.bind(highlight_barracks))
	barracks_click_area.mouse_exited.connect(hide_all_highlights)
	barracks_click_area.pressed.connect(_on_barracks_pressed)

	expedition_click_area.mouse_entered.connect(show_highlight.bind(highlight_expedition))
	expedition_click_area.mouse_exited.connect(hide_all_highlights)
	expedition_click_area.pressed.connect(_on_expedition_pressed)

	close_recruit_button.pressed.connect(_on_close_recruit_pressed)
	close_barracks_button.pressed.connect(_on_close_barracks_pressed)

	_create_test_recruits()
	recruit_panel.hide()
	barracks_panel.hide()
	info_message.hide()
	fade_in()


func hide_all_highlights() -> void:
	highlight_recruit.hide()
	highlight_blacksmith.hide()
	highlight_market.hide()
	highlight_hospital.hide()
	highlight_barracks.hide()
	highlight_expedition.hide()


func show_highlight(target: TextureRect) -> void:
	hide_all_highlights()
	target.show()


func fade_in() -> void:
	fade_rect.show()
	fade_rect.color = Color.BLACK
	fade_rect.modulate.a = 1.0
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.45)
	await tween.finished


func _create_test_recruits() -> void:
	available_heroes = [
		_create_test_hero("Добрыня", "Крепкая хватка", "Упрямый"),
		_create_test_hero("Мирослава", "Быстрая реакция", "Осторожная"),
		_create_test_hero("Радомир", "Тёмная учёность", "Наблюдательный")
	]


func _create_test_hero(hero_name: String, passive_skill: String, trait_name: String) -> HeroData:
	var hero := HeroData.new()
	hero.hero_name = hero_name
	hero.passive_skill = passive_skill
	hero.traits = [trait_name]
	hero.ability_slots = ["", "", "", ""]
	hero.item_slots = {
		"hand_1": null,
		"hand_2": null,
		"accessory_1": null,
		"accessory_2": null
	}
	hero.strength = rng.randi_range(1, 6)
	hero.agility = rng.randi_range(1, 6)
	hero.intelligence = rng.randi_range(1, 6)

	# Base stats are hidden from the UI for now, but they drive all visible stats.
	LevelFormulaManager.apply_base_stats_to_hero(hero)
	hero.ensure_id()

	return hero


func _on_recruit_pressed() -> void:
	hide_all_highlights()
	info_message.hide()
	barracks_panel.hide()
	recruit_panel.show()
	_render_recruit_list()


func _on_barracks_pressed() -> void:
	hide_all_highlights()
	info_message.hide()
	recruit_panel.hide()
	barracks_panel.show()
	_render_barracks_list()


func _on_blacksmith_pressed() -> void:
	_show_locked_message("Кузнец появится позже")


func _on_market_pressed() -> void:
	_show_locked_message("Рынок появится позже")


func _on_hospital_pressed() -> void:
	_show_locked_message("Больница появится позже")


func _on_expedition_pressed() -> void:
	_show_locked_message("Вылазка появится позже")


func _show_locked_message(message: String) -> void:
	hide_all_highlights()
	recruit_panel.hide()
	barracks_panel.hide()
	info_message.text = message
	info_message.show()


func _on_close_recruit_pressed() -> void:
	recruit_panel.hide()


func _on_close_barracks_pressed() -> void:
	barracks_panel.hide()


func _render_recruit_list() -> void:
	_clear_container(recruit_list)

	for hero in available_heroes:
		var row := _create_hero_panel()
		var row_box := row.get_node("Margin/Box") as HBoxContainer
		var info := _create_label(_get_recruit_text(hero))
		var hire_button := Button.new()
		hire_button.custom_minimum_size = Vector2(130, 42)

		if GameState.is_hero_hired(hero):
			hire_button.text = "Уже нанят"
			hire_button.disabled = true
		else:
			hire_button.text = "Нанять"
			hire_button.pressed.connect(_on_hire_pressed.bind(hero, hire_button))

		row_box.add_child(info)
		row_box.add_child(hire_button)
		recruit_list.add_child(row)


func _render_barracks_list() -> void:
	_clear_container(barracks_list)

	var hired_heroes := GameState.get_hired_heroes()
	if hired_heroes.is_empty():
		barracks_list.add_child(_create_label("Нанятых героев пока нет"))
		return

	for hero in hired_heroes:
		var row := _create_hero_panel()
		var row_box := row.get_node("Margin/Box") as HBoxContainer
		row_box.add_child(_create_label(_get_barracks_text(hero)))
		barracks_list.add_child(row)


func _on_hire_pressed(hero: HeroData, hire_button: Button) -> void:
	if GameState.hire_hero(hero):
		hire_button.text = "Уже нанят"
		hire_button.disabled = true
		info_message.text = "%s нанят" % hero.hero_name
	else:
		info_message.text = "%s уже в отряде" % hero.hero_name

	info_message.show()


func _create_hero_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)

	var box := HBoxContainer.new()
	box.name = "Box"
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 12)

	margin.add_child(box)
	panel.add_child(margin)

	return panel


func _create_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _clear_container(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _get_recruit_text(hero: HeroData) -> String:
	return "%s\nУровень: %d | Сила: %d | Ловкость: %d | Интеллект: %d\nПассивное умение: %s\nЧерты: %s" % [
		hero.hero_name,
		hero.level,
		hero.strength,
		hero.agility,
		hero.intelligence,
		hero.passive_skill,
		_format_traits(hero.traits)
	]


func _get_barracks_text(hero: HeroData) -> String:
	return "%s\nУровень: %d\nЗдоровье: %d/%d\nБроня: %d\nУрон тяжелым оружием: %d\nУрон легким оружием: %d\nУрон магией: %d\nСкорость: %d\nУклон: %d\nШанс крита: %d\nМеткость: %d\nПассивное умение: %s\nЧерты: %s" % [
		hero.hero_name,
		hero.level,
		hero.current_health,
		int(hero.max_health),
		int(hero.armor),
		int(hero.heavy_weapon_damage),
		int(hero.light_weapon_damage),
		int(hero.magic_damage),
		int(hero.speed),
		int(hero.dodge),
		int(hero.crit_chance),
		int(hero.accuracy),
		hero.passive_skill,
		_format_traits(hero.traits)
	]


func _format_traits(traits: Array[String]) -> String:
	if traits.is_empty():
		return "Нет"

	var trait_names := PackedStringArray()
	for trait_name in traits:
		trait_names.append(trait_name)

	return ", ".join(trait_names)
