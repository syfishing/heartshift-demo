extends Node2D

@export var chart: ChartData
@export var note_scene: PackedScene
@export var dummy_note_scene: PackedScene
@onready var audio_player = $"../MusicPlayer"

@onready var screen_center = get_viewport_rect().size

var next_note_index: int = 0
@export var travel_time: float = 5
var active_notes: Array[Node2D] = []

var time_since_last_dummy: float = 0.0
@export var dummy_spawn_interval: float = 0.5
@export var sine_decay_rate: float = 0.3

var dummy_spawn_count: int = 0

func _ready() -> void:
	#start audio
	audio_player.stream = chart.audio
	audio_player.playing = true
	
	%SongLabel.text = chart.name
	%DetailLabel.text = chart.stage_level
	
func _process(delta):
	if not audio_player.playing: return
	
	#If no more notes left
	if next_note_index == chart.notes.size():
		time_since_last_dummy += delta
		if time_since_last_dummy >= dummy_spawn_interval:
			time_since_last_dummy -= dummy_spawn_interval
			spawn_dummy_note()
		
	if next_note_index < chart.notes.size():
		var song_time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix()
		if song_time >= chart.notes[next_note_index].hit_time - travel_time:
			spawn_note(chart.notes[next_note_index])
			next_note_index += 1
	

func spawn_dummy_note() -> void:
	var n = dummy_note_scene.instantiate()
	var start_x = screen_center.x * 8
	var center_y = 325.0
	var amplitude = 150.0 * exp(-dummy_spawn_count * sine_decay_rate)
	var direction = 1.0 if dummy_spawn_count % 2 == 0 else -1.0
	var y = center_y + direction * amplitude
	
	dummy_spawn_count += 1
	n.spawn_pos = Vector2(start_x, y)
	n.hit_pos = Vector2(250, y)
	n.travel_time = travel_time

	add_child(n)
	active_notes.push_back(n)
	$"../Curve".point_nodes = active_notes


func spawn_note(data: NoteData):
	var n = note_scene.instantiate()
	var start_x = screen_center.x * 8
	var start_y: int

	if data.track == 0:
		start_y = 175
	elif data.track == 1:
		start_y = 325
	else:
		start_y = 475
	
	var spawn_position = Vector2(start_x, start_y)

	n.hit_time = data.hit_time
	n.end_time = data.end_time
	n.travel_time = travel_time / data.travel_time_multiplier
	n.spawn_pos = spawn_position
	n.hit_pos = Vector2(250, spawn_position.y)
	n.bpm = chart.bpm
	n.audio_player_ref = audio_player
	
	add_child(n)
	active_notes.push_back(n)
	$"../Curve".point_nodes = active_notes

func remove_active_note(note: Node) -> void:
	#just removes the note from the active notes and updates the curve sketcher
	active_notes.erase(note)
	$"../Curve".point_nodes = active_notes
