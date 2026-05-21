extends Control

const HUB_SCENE_PATH := "res://scenes/hub/Hub.tscn"

var overlay_frames: Array[Texture2D] = [
	preload("res://MainMenu_Overlay_01_1920x1080.png"),
	preload("res://MainMenu_Overlay_02_1920x1080.png"),
	preload("res://MainMenu_Overlay_03_1920x1080.png"),
	preload("res://MainMenu_Overlay_04_1920x1080.png")
]
var current_overlay_frame := 0
var is_transitioning := false

@onready var animated_overlay: TextureRect = %AnimatedOverlay
@onready var menu_buttons: Control = %MenuButtons
@onready var settings_panel: Control = %SettingsPanel
@onready var start_button: Button = %StartButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton
@onready var settings_title_label: Label = %SettingsTitleLabel
@onready var resolution_label: Label = %ResolutionLabel
@onready var resolution_option: OptionButton = %ResolutionOption
@onready var language_label: Label = %LanguageLabel
@onready var language_option: OptionButton = %LanguageOption
@onready var fullscreen_check_box: CheckBox = %FullscreenCheckBox
@onready var back_button: Button = %BackButton
@onready var fade_rect: ColorRect = %FadeRect
@onready var overlay_animation_timer: Timer = %OverlayAnimationTimer


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_show_settings)
	exit_button.pressed.connect(_on_exit_pressed)
	resolution_option.item_selected.connect(_on_resolution_selected)
	language_option.item_selected.connect(_on_language_selected)
	fullscreen_check_box.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_show_main)
	overlay_animation_timer.timeout.connect(_on_overlay_animation_timer_timeout)
	SettingsManager.language_changed.connect(_apply_translations)

	continue_button.disabled = true
	animated_overlay.texture = overlay_frames[0]
	overlay_animation_timer.start()

	fade_rect.color = Color.BLACK
	fade_rect.modulate.a = 0.0
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_populate_resolution_options()
	_populate_language_options()
	_sync_settings_controls()
	_apply_translations()
	_show_main()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and settings_panel.visible:
		_show_main()


func _on_overlay_animation_timer_timeout() -> void:
	current_overlay_frame = (current_overlay_frame + 1) % overlay_frames.size()
	animated_overlay.texture = overlay_frames[current_overlay_frame]


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
	start_button.text = SettingsManager.t("main_menu.start")
	continue_button.text = SettingsManager.t("main_menu.continue")
	settings_button.text = SettingsManager.t("main_menu.settings")
	exit_button.text = SettingsManager.t("main_menu.quit")
	settings_title_label.text = SettingsManager.t("settings.title")
	resolution_label.text = SettingsManager.t("settings.resolution")
	language_label.text = SettingsManager.t("settings.language")
	fullscreen_check_box.text = SettingsManager.t("settings.fullscreen")
	back_button.text = SettingsManager.t("settings.back")


func _show_main() -> void:
	menu_buttons.show()
	settings_panel.hide()
	start_button.grab_focus()


func _show_settings() -> void:
	menu_buttons.hide()
	settings_panel.show()
	_sync_settings_controls()
	resolution_option.grab_focus()


func _on_start_pressed() -> void:
	if is_transitioning:
		return

	if not ResourceLoader.exists(HUB_SCENE_PATH):
		push_error("Hub scene was not found: %s" % HUB_SCENE_PATH)
		return

	is_transitioning = true
	await fade_out()

	var error := get_tree().change_scene_to_file(HUB_SCENE_PATH)
	if error != OK:
		is_transitioning = false
		fade_rect.modulate.a = 0.0
		push_error("Could not open hub scene: %s" % HUB_SCENE_PATH)


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


func _on_exit_pressed() -> void:
	get_tree().quit()


func fade_out() -> void:
	fade_rect.show()
	fade_rect.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.45)
	await tween.finished
