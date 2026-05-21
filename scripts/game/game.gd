extends Control

@export_file("*.tscn") var main_menu_scene_path := "res://scenes/main_menu/MainMenu.tscn"
@export_file("*.tscn") var current_scene_path := "res://scenes/game/game.tscn"

@onready var title_label: Label = %TitleLabel
@onready var status_label: Label = %StatusLabel
@onready var save_button: Button = %SaveButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	save_button.pressed.connect(_on_save_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	SettingsManager.language_changed.connect(_apply_translations)
	_apply_translations()
	SaveManager.mark_scene_for_continue(current_scene_path)


func _on_save_pressed() -> void:
	SaveManager.mark_scene_for_continue(current_scene_path)
	status_label.text = SettingsManager.t("game.saved")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene_path)


func _apply_translations() -> void:
	title_label.text = SettingsManager.t("game.title")
	status_label.text = SettingsManager.t("game.status")
	save_button.text = SettingsManager.t("game.save")
	menu_button.text = SettingsManager.t("game.back_to_menu")
