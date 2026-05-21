extends Node

signal language_changed

const SETTINGS_PATH := "user://settings.cfg"
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]
const LANGUAGES: Array[String] = ["ru", "en"]
const LANGUAGE_NAMES := {
	"ru": "Русский",
	"en": "English"
}
const TRANSLATIONS := {
	"ru": {
		"main_menu.title": "Главное меню",
		"main_menu.start": "Начать игру",
		"main_menu.continue": "Продолжить",
		"main_menu.settings": "Настройки",
		"main_menu.quit": "Выход",
		"settings.title": "Настройки",
		"settings.resolution": "Разрешение",
		"settings.language": "Язык",
		"settings.fullscreen": "Полный экран",
		"settings.back": "Назад",
		"game.title": "Игровая сцена",
		"game.status": "Игровая заглушка готова.",
		"game.saved": "Сохранено",
		"game.save": "Сохранить",
		"game.back_to_menu": "В меню"
	},
	"en": {
		"main_menu.title": "Main Menu",
		"main_menu.start": "Start Game",
		"main_menu.continue": "Continue",
		"main_menu.settings": "Settings",
		"main_menu.quit": "Exit",
		"settings.title": "Settings",
		"settings.resolution": "Resolution",
		"settings.language": "Language",
		"settings.fullscreen": "Fullscreen",
		"settings.back": "Back",
		"game.title": "Game Scene",
		"game.status": "The game placeholder is ready.",
		"game.saved": "Saved",
		"game.save": "Save",
		"game.back_to_menu": "Back to Menu"
	}
}

var resolution := Vector2i(1280, 720)
var fullscreen := false
var language_code := "ru"


func _ready() -> void:
	load_settings()
	apply_language()
	apply_settings()


func load_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if error != OK:
		return

	var width := int(config.get_value("display", "width", resolution.x))
	var height := int(config.get_value("display", "height", resolution.y))

	resolution = Vector2i(width, height)
	if not RESOLUTIONS.has(resolution):
		resolution = RESOLUTIONS[0]

	fullscreen = bool(config.get_value("display", "fullscreen", fullscreen))
	language_code = str(config.get_value("language", "code", language_code))
	if not LANGUAGES.has(language_code):
		language_code = LANGUAGES[0]


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "width", resolution.x)
	config.set_value("display", "height", resolution.y)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("language", "code", language_code)
	config.save(SETTINGS_PATH)


func apply_settings() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(resolution)
	call_deferred("_center_window")


func set_resolution(value: Vector2i) -> void:
	resolution = value
	apply_settings()
	save_settings()


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	apply_settings()
	save_settings()


func set_language(code: String) -> void:
	if not LANGUAGES.has(code) or language_code == code:
		return

	language_code = code
	apply_language()
	save_settings()
	language_changed.emit()


func get_resolution_index() -> int:
	var index := RESOLUTIONS.find(resolution)
	if index == -1:
		return 0

	return index


func get_language_index() -> int:
	var index := LANGUAGES.find(language_code)
	if index == -1:
		return 0

	return index


func get_language_name(code: String) -> String:
	return str(LANGUAGE_NAMES.get(code, code))


func apply_language() -> void:
	TranslationServer.set_locale(language_code)


func t(key: String) -> String:
	var default_language: Dictionary = TRANSLATIONS["ru"]
	var language: Dictionary = TRANSLATIONS.get(language_code, default_language)

	return str(language.get(key, default_language.get(key, key)))


func _center_window() -> void:
	if fullscreen:
		return

	var screen := DisplayServer.window_get_current_screen()
	var screen_position := DisplayServer.screen_get_position(screen)
	var screen_size := DisplayServer.screen_get_size(screen)
	var window_position := Vector2i(
		screen_position.x + max(0, int((screen_size.x - resolution.x) / 2.0)),
		screen_position.y + max(0, int((screen_size.y - resolution.y) / 2.0))
	)

	DisplayServer.window_set_position(window_position)
