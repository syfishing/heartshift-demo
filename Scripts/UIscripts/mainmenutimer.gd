extends Node2D

@export var current_numberline_pos = 0.0

var bpm : int = 70
var beat_interval := 60.0 / bpm
var next_beat_time := 0.0
var last_t := 0.0

func _process(delta):
	var t = AudioHub.menumusicplayer.get_playback_position()

	# Detect loop (playback position jumped backwards)
	if t < last_t:
		# Reset beat timer relative to new loop
		next_beat_time = t + beat_interval

	# Fire beat events
	if t >= next_beat_time:
		on_timeout()
		next_beat_time += beat_interval

	last_t = t


func on_timeout() -> void:
	if (current_numberline_pos + 30.88) >= 123.25:
		current_numberline_pos = 30.88
	else:
		current_numberline_pos += 30.88

	#print(current_numberline_pos)
