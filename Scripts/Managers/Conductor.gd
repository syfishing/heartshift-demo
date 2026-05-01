extends Node2D

@export var chart: ChartData
@export var note_scene: PackedScene
@onready var audio_player = $"../AudioStreamPlayer"

@onready var screen_center = get_viewport_rect().size

var next_note_index: int = 0
@export var travel_time: float = 5
var active_notes: Array[Node2D] = []

func _process(_delta):
	if not audio_player.playing: return
	
	#time sync
	var song_time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	
	if next_note_index < chart.notes.size():
		if song_time >= chart.notes[next_note_index].hit_time - travel_time:
			spawn_note(chart.notes[next_note_index])
			next_note_index += 1


func spawn_note(data: NoteData):
	var n = note_scene.instantiate()
	
	var start_y = 0
	var start_x = screen_center.x * 8
	
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
	
	n.audio_player_ref = audio_player
	
	add_child(n)
	active_notes.push_back(n)

	#just syncs the curve sketcher to the active notes
	$"../Curve".point_nodes = active_notes

func remove_active_note(note: Node) -> void:
	#just removes the note from the active notes and updates the curve sketcher
	active_notes.erase(note)
	$"../Curve".point_nodes = active_notes
