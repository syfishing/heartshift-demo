extends Camera2D

@export var pulse: bool = false
@export var rotation_return_speed: float = 8.0

@export var current_numberline_pos = 0.0

@export var beat_offset_seconds: float = -0.1

var bpm : int = 200
var beat_interval := 60.0 / bpm
var next_beat_time := 0.0
var last_t := 0.0

func _ready():
	# Apply offset at start
	next_beat_time = beat_offset_seconds

func _process(delta):
	var t = AudioHub.trackmusicplayer.get_playback_position()

	# Detect loop (playback position jumped backwards)
	if t < last_t:
		# Reset beat timer relative to new loop, including offset
		next_beat_time = t + beat_interval + beat_offset_seconds

	# Fire beat events
	if t >= next_beat_time:
		on_timeout()
		next_beat_time += beat_interval

	last_t = t
	rotation = lerp_angle(rotation, 0.0, clamp(delta * rotation_return_speed, 0.0, 1.0))

func on_timeout() -> void:
	if pulse != true: return
	if (current_numberline_pos + 30.88) >= 123.25:
		current_numberline_pos = 30.88
	else:
		current_numberline_pos += 30.88

	#print(current_numberline_pos)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", Vector2(0.99, 0.99), 0.1)
	tween.tween_property(self, "zoom", Vector2(1.0, 1.0), 0.2)
