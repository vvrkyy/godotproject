extends Node

const SAVE_PATH := "user://save_game.json"


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func start_new_game(scene_path: String) -> void:
	save_game({
		"scene_path": scene_path,
		"created_at": Time.get_datetime_string_from_system()
	})


func mark_scene_for_continue(scene_path: String) -> void:
	var data := load_game()
	data["scene_path"] = scene_path
	save_game(data)


func get_saved_scene_path(fallback_scene_path: String) -> String:
	var data := load_game()
	var scene_path := str(data.get("scene_path", fallback_scene_path))

	if ResourceLoader.exists(scene_path):
		return scene_path

	return fallback_scene_path


func save_game(data: Dictionary) -> void:
	data["updated_at"] = Time.get_datetime_string_from_system()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing: %s" % SAVE_PATH)
		return

	file.store_string(JSON.stringify(data, "\t"))


func load_game() -> Dictionary:
	if not has_save():
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed

	return {}
