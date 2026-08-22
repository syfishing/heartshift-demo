extends Node

var save_path = "user://savefile.save"

var save_data = {
	"stage": 0
}

var ranks = {
	"dreamon": {
		"score": 0,
		"rank": "N"
	},
	"technicolor": {
		"score": 0,
		"rank": "N"
	},
	"ididitagain": {
		"score": 0,
		"rank": "N"
	},
	"lastpulse": {
		"score": 0,
		"rank": "N"
	}
}

func _enter_tree() -> void:
	load_data()
	

func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(save_data, true)
	file.store_var(ranks, true)
	print('saved')

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		
		save_data = file.get_var(true)
		ranks = file.get_var(true)
		
	
	else:
		return
