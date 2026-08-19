extends Control

var save_path = "user://options.save"

var sfx_volume = 100.0
var music_volume = 100.0

var first_lane = InputMap.action_get_events("lane1")[0]
var second_lane = InputMap.action_get_events("lane2")[0]
var third_lane = InputMap.action_get_events("lane3")[0]
var select = InputMap.action_get_events("Select")[0]

var note_speed = 50.0

func _enter_tree() -> void:
	load_data()
	pass
	

func _process(delta: float) -> void:
	pass

func save():
	first_lane = InputMap.action_get_events("lane1")[0]
	second_lane = InputMap.action_get_events("lane2")[0]
	third_lane = InputMap.action_get_events("lane3")[0]
	select = InputMap.action_get_events("Select")[0]

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


func _on_button_pressed() -> void:
	save()


func _on_sfx_volume_drag_ended(value_changed: bool) -> void:
	
	pass # Replace with function body.


func _on_music_volume_drag_ended(value_changed: bool) -> void:
	pass # Replace with function body.
