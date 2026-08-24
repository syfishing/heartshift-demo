extends Node2D

@export var chart: ChartData
@export var note_scene: PackedScene
@export var dummy_note_scene: PackedScene
@onready var audio_player = AudioHub.trackmusicplayer

@onready var screen_center = get_viewport_rect().size

var next_note_index: int = 0
@export var travel_time: float = 5
var active_notes: Array[Node2D] = []

var time_since_last_dummy: float = 0.0
@export var dummy_spawn_interval: float = 0.5
@export var sine_decay_rate: float = 0.3

@export var audio_offset_ms: float = 0.0

@export var clock_smoothing: float = 4.0
@export var clock_max_correction: float = 0.10
@export var clock_resync_threshold: float = 0.10
var _clock_running: bool = false

var dummy_spawn_count: int = 0

const NOTE_HIT_X: float = 250.0
const NOTE_SPAWN_SCREENS: float = 8.0
const LANE_Y: Array[float] = [175.0, 325.0, 475.0]
var song_time: float = 0.0
var _pending_notes: Array[Array] = [[], [], []]
var save_path = "user://options.save"

func _ready() -> void:
	process_priority = -100

func _process(delta):
	_update_song_time(delta)

	if not audio_player.playing: return

	#If no more notes left
	if next_note_index == chart.notes.size():
		time_since_last_dummy += delta
		if time_since_last_dummy >= dummy_spawn_interval:
			time_since_last_dummy -= dummy_spawn_interval
			spawn_dummy_note()

	if next_note_index < chart.notes.size():
		if song_time >= chart.notes[next_note_index].hit_time - travel_time:
			spawn_note(chart.notes[next_note_index])
			next_note_index += 1


func _update_song_time(delta: float) -> void:
	if not audio_player.playing:
		_clock_running = false
		return

	var raw: float = (
		audio_player.get_playback_position()
		+ AudioServer.get_time_since_last_mix()
		- AudioServer.get_output_latency()
		+ audio_offset_ms / 1000.0
	)

	if not _clock_running:
		song_time = raw
		_clock_running = true
		return


	song_time += delta * audio_player.pitch_scale

	var drift: float = raw - song_time
	if absf(drift) > clock_resync_threshold:
		song_time = raw
	else:
		var max_step: float = clock_max_correction * delta
		song_time += clampf(drift * clock_smoothing * delta, -max_step, max_step)

func is_playing() -> bool:
	return audio_player.playing


func get_note_speed() -> float:
	if travel_time <= 0.0:
		return 0.0
	return (get_viewport_rect().size.x * NOTE_SPAWN_SCREENS - NOTE_HIT_X) / travel_time


func get_hittable_note(lane: int, time: float, window: float) -> Node2D:
	if lane < 0 or lane >= _pending_notes.size():
		return null

	var best: Node2D = null
	for note in _pending_notes[lane]:
		if not is_instance_valid(note):
			continue
		if absf(time - note.hit_time) > window:
			continue
		if best == null or note.hit_time < best.hit_time:
			best = note

	return best


func take_missed_note(lane: int, time: float, window: float) -> Node2D:
	if lane < 0 or lane >= _pending_notes.size():
		return null

	var missed: Node2D = null
	for note in _pending_notes[lane]:
		if not is_instance_valid(note):
			continue
		if time <= note.hit_time + window:
			continue
		if missed == null or note.hit_time < missed.hit_time:
			missed = note

	if missed != null:
		_pending_notes[lane].erase(missed)

	return missed


func resolve_note(note: Node2D) -> void:
	var lane: int = note.lane
	if lane < 0 or lane >= _pending_notes.size():
		return

	_pending_notes[lane].erase(note)


func spawn_dummy_note() -> void:
	var n = dummy_note_scene.instantiate()
	var start_x = screen_center.x * NOTE_SPAWN_SCREENS
	var center_y = LANE_Y[1]
	var amplitude = 150.0 * exp(-dummy_spawn_count * sine_decay_rate)
	var direction = 1.0 if dummy_spawn_count % 2 == 0 else -1.0
	var y = center_y + direction * amplitude

	dummy_spawn_count += 1
	n.spawn_pos = Vector2(start_x, y)
	n.hit_pos = Vector2(NOTE_HIT_X, y)
	n.travel_time = travel_time

	add_child(n)
	active_notes.push_back(n)
	$"../Curve".point_nodes = active_notes


func spawn_note(data: NoteData):
	var n = note_scene.instantiate()
	var start_x = screen_center.x * NOTE_SPAWN_SCREENS
	var lane: int = clampi(data.track, 0, LANE_Y.size() - 1)

	var spawn_position = Vector2(start_x, LANE_Y[lane])

	n.hit_time = data.hit_time
	n.end_time = data.end_time
	n.travel_time = travel_time / data.travel_time_multiplier
	n.spawn_pos = spawn_position
	n.hit_pos = Vector2(NOTE_HIT_X, spawn_position.y)
	n.bpm = chart.bpm
	n.lane = lane
	n.conductor = self

	add_child(n)
	active_notes.push_back(n)
	_pending_notes[lane].push_back(n)
	$"../Curve".point_nodes = active_notes

func remove_active_note(note: Node) -> void:
	#just removes the note from the active notes and updates the curve sketcher
	active_notes.erase(note)
	$"../Curve".point_nodes = active_notes


func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)

		file.get_var() # sfx_volume
		file.get_var() # music_volume

		file.get_var(true) # first_lane
		file.get_var(true) # second_lane
		file.get_var(true) # third_lane
		file.get_var(true) # select

		var note_speed: float = file.get_var()
		travel_time = 15 - note_speed
