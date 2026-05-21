extends Control

@export_file("*.tscn") var game_scene_path := "res://scenes/game/game.tscn"

@onready var main_panel: Control = %MainPanel
@onready var settings_panel: Control = %SettingsPanel
@onready var main_title_label: Label = %MainTitleLabel
@onready var start_button: Button = %StartButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var settings_title_label: Label = %SettingsTitleLabel
@onready var resolution_label: Label = %ResolutionLabel
@onready var resolution_option: OptionButton = %ResolutionOption
@onready var language_label: Label = %LanguageLabel
@onready var language_option: OptionButton = %LanguageOption
@onready var fullscreen_check_box: CheckBox = %FullscreenCheckBox
@onready var back_button: Button = %BackButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_show_settings)
	quit_button.pressed.connect(_on_quit_pressed)
	resolution_option.item_selected.connect(_on_resolution_selected)
	language_option.item_selected.connect(_on_language_selected)
	fullscreen_check_box.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_show_main)
	SettingsManager.language_changed.connect(_apply_translations)

	_populate_resolution_options()
	_populate_language_options()
	_sync_settings_controls()
	_apply_translations()
	_show_main()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and settings_panel.visible:
		_show_main()


func _populate_resolution_options() -> void:
	resolution_option.clear()

	for available_resolution in SettingsManager.RESOLUTIONS:
		resolution_option.add_item("%d x %d" % [available_resolution.x, available_resolution.y])


func _populate_language_options() -> void:
	language_option.clear()

	for language_code in SettingsManager.LANGUAGES:
		language_option.add_item(SettingsManager.get_language_name(language_code))


func _sync_settings_controls() -> void:
	resolution_option.select(SettingsManager.get_resolution_index())
	language_option.select(SettingsManager.get_language_index())
	fullscreen_check_box.set_pressed_no_signal(SettingsManager.fullscreen)


func _apply_translations() -> void:
	main_title_label.text = SettingsManager.t("main_menu.title")
	start_button.text = SettingsManager.t("main_menu.start")
	continue_button.text = SettingsManager.t("main_menu.continue")
	settings_button.text = SettingsManager.t("main_menu.settings")
	quit_button.text = SettingsManager.t("main_menu.quit")
	settings_title_label.text = SettingsManager.t("settings.title")
	resolution_label.text = SettingsManager.t("settings.resolution")
	language_label.text = SettingsManager.t("settings.language")
	fullscreen_check_box.text = SettingsManager.t("settings.fullscreen")
	back_button.text = SettingsManager.t("settings.back")


func _show_main() -> void:
	main_panel.show()
	settings_panel.hide()
	_refresh_continue_state()
	start_button.grab_focus()


func _show_settings() -> void:
	main_panel.hide()
	settings_panel.show()
	_sync_settings_controls()
	resolution_option.grab_focus()


func _refresh_continue_state() -> void:
	continue_button.disabled = not SaveManager.has_save()


func _on_start_pressed() -> void:
	if not ResourceLoader.exists(game_scene_path):
		push_error("Game scene was not found: %s" % game_scene_path)
		return

	SaveManager.start_new_game(game_scene_path)
	get_tree().change_scene_to_file(game_scene_path)


func _on_continue_pressed() -> void:
	var scene_path := SaveManager.get_saved_scene_path(game_scene_path)
	if not ResourceLoader.exists(scene_path):
		push_error("Saved scene was not found: %s" % scene_path)
		return

	get_tree().change_scene_to_file(scene_path)


func _on_resolution_selected(index: int) -> void:
	if index < 0 or index >= SettingsManager.RESOLUTIONS.size():
		return

	SettingsManager.set_resolution(SettingsManager.RESOLUTIONS[index])


func _on_language_selected(index: int) -> void:
	if index < 0 or index >= SettingsManager.LANGUAGES.size():
		return

	SettingsManager.set_language(SettingsManager.LANGUAGES[index])


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	SettingsManager.set_fullscreen(toggled_on)
	fullscreen_check_box.set_pressed_no_signal(SettingsManager.fullscreen)


func _on_quit_pressed() -> void:
	get_tree().quit()
