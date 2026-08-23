extends Control

var save_path = "user://options.save"
var save_progress_path = "user://savefile.save"

var sfx_volume = 0.0
var music_volume = 0.0

var first_lane = InputMap.action_get_events("lane1")[0]
var second_lane = InputMap.action_get_events("lane2")[0]
var third_lane = InputMap.action_get_events("lane3")[0]
var select = InputMap.action_get_events("Select")[0]

var note_speed = 50.0

func _enter_tree() -> void:
	print("I ENTEREDD")
	load_data()

func _process(delta: float) -> void:
	if (Input.is_action_just_released("Exit")):
		%ExitSaveButton.pressed.emit()

func save():
	first_lane = InputMap.action_get_events("lane1")[0]
	second_lane = InputMap.action_get_events("lane2")[0]
	third_lane = InputMap.action_get_events("lane3")[0]
	select = InputMap.action_get_events("Select")[0]
	
	sfx_volume = %SfxVolume.value
	music_volume = %MusicVolume.value

	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(sfx_volume)
	file.store_var(music_volume)
	file.store_var(first_lane, true)
	file.store_var(second_lane, true)
	file.store_var(third_lane, true)
	file.store_var(select, true)
	file.store_var(note_speed)
	print("saved")

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)

		sfx_volume = file.get_var()
		music_volume = file.get_var()

		first_lane = file.get_var(true)
		second_lane = file.get_var(true)
		third_lane = file.get_var(true)
		select = file.get_var(true)

		note_speed = file.get_var()
		
		%SfxVolume.value = sfx_volume
		%MusicVolume.value = music_volume

		if first_lane is InputEvent:
			InputMap.action_erase_events("lane1")
			InputMap.action_add_event("lane1", first_lane)

		if second_lane is InputEvent:
			InputMap.action_erase_events("lane2")
			InputMap.action_add_event("lane2", second_lane)

		if third_lane is InputEvent:
			InputMap.action_erase_events("lane3")
			InputMap.action_add_event("lane3", third_lane)

		if select is InputEvent:
			InputMap.action_erase_events("Select")
			InputMap.action_add_event("Select", select)

	else:
		return


func delete_save():
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
		print("Save deleted")
	else:
		print("No save file found")
	load_data()
		
func _on_delete_progress_pressed() -> void:
	if FileAccess.file_exists(save_progress_path):
		DirAccess.remove_absolute(save_progress_path)
		print("Save progress deleted")
	else:
		print("No save progress file found")
	load_data()

func _on_button_pressed() -> void:
	save()
	%TransitionPlayer.play("TransitionOut")


func _on_sfx_volume_drag_ended(_value_changed: bool) -> void:
	AudioHub.sfxplayer.volume_db = %SfxVolume.value
	AudioHub.play_note_sfx()


func _on_music_volume_drag_ended(_value_changed: bool) -> void:
	AudioHub.menumusicplayer.volume_db = %MusicVolume.value


func _on_transition_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "TransitionIn": return
	get_tree().change_scene_to_file("res://Prefabs/Scenes/MainMenu.tscn")
	pass # Replace with function body.
