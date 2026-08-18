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
	

func _process(delta: float) -> void:
	pass

func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(sfx_volume)
	file.store_var(music_volume)
	file.store_var(first_lane)
	file.store_var(second_lane)
	file.store_var(third_lane)
	file.store_var(select)
	file.store_var(note_speed)
	

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		sfx_volume = file.get_var()
		music_volume = file.get_var()
		first_lane = file.get_var()
		second_lane = file.get_var()
		third_lane = file.get_var()
		select = file.get_var()
		note_speed = file.get_var()
	else:
		return
	
