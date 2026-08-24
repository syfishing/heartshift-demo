extends Node

var save_path = "user://savefile.save"

var stage = 0

var ranks = {}

func _enter_tree() -> void:
	load_data()

func unlock_next_stage(index: int) -> void:
	stage = max(stage, index + 1)
	save()


func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(stage, true)
	file.store_var(ranks, true)
	print('saved')

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		
		stage = file.get_var(true)
		ranks = file.get_var(true)
		
	
	else:
		return
