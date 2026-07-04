extends Node2D
@export var current_numberline_pos = 0.0

var bpm : int = 140
var beat_interval := 60.0 / bpm
var next_beat_time := 0.0

func _process(delta):
	var t = AudioHub.menumusicplayer.get_playback_position()

	if t >= next_beat_time:
		on_timeout()
		next_beat_time += beat_interval


func on_timeout() -> void:
	if (current_numberline_pos + 30.88) >= 123.25:
		current_numberline_pos = 30.88
	else:
		current_numberline_pos += 30.88
		print(current_numberline_pos)
