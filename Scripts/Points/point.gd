extends Node2D

enum NoteState {
	PENDING,
	HOLDING,
	COMPLETED,
	FAILED,
}

# Variables down from Conductor
var hit_time: float = 0.0
var end_time: float = 0.0
var travel_time: float = 2.0
var spawn_pos: Vector2
var hit_pos: Vector2
var bpm: float

@onready var screen_center = get_viewport_rect().size

# If its hit
var hit = false
var note_state: int = NoteState.PENDING

var audio_player_ref: AudioStreamPlayer
var _last_song_time: float = 0.0
var _next_beat_time: float = -1.0

func is_hold_note() -> bool:
	return end_time > 0.0

func start_hit() -> void:
	if note_state != NoteState.PENDING:
		return

	hit = true
	if is_hold_note():
		note_state = NoteState.HOLDING
		var beat_duration = 60.0 / bpm
		_next_beat_time = ceil(hit_time / beat_duration) * beat_duration
		# position = hit_pos
		$Spray.emitting = true
		$HoldSpray.emitting = true
		$HoldSpray.position = Vector2(250, global_position.y)
		$HoldSpray/Dot.emitting = true
		$PointHead.visible = false
	else:
		note_state = NoteState.COMPLETED
		$Spray.emitting = true
		$PointHead.visible = false
		
	
func complete_hold() -> void:
	if note_state != NoteState.HOLDING:
		return

	note_state = NoteState.COMPLETED
	$HoldSpray.emitting = false
	$HoldSpray/Dot.emitting = false

func fail_note() -> void:
	if note_state == NoteState.COMPLETED or note_state == NoteState.FAILED:
		return

	hit = true
	note_state = NoteState.FAILED
	$HoldSpray.emitting = false
	$HoldSpray/Dot.emitting = false

func _remove_from_conductor() -> void:
	if get_parent().has_method("remove_active_note"):
		get_parent().remove_active_note(self )


func _ready() -> void:
	position = spawn_pos
	if is_hold_note():
		var hold_duration = end_time - hit_time
		$PointTail.position.x = - (hit_pos.x - spawn_pos.x) * hold_duration / travel_time # Dumb ways to die while coding, FORGET THE MINUS SIGN
		$PointBody.add_point(Vector2($PointTail.position.x, 0))
		$PointBody.add_point(Vector2(0, 0))

func _process(delta: float) -> void:
	if not audio_player_ref:
		return
		
	visible = true

	if audio_player_ref.playing:
		_last_song_time = audio_player_ref.get_playback_position() + AudioServer.get_time_since_last_mix()
	else:
		_last_song_time += delta

	if note_state == NoteState.HOLDING:
		$Area2D/CollisionShape2D.disabled = true
		if _next_beat_time >= 0.0:
			while _last_song_time >= _next_beat_time:
				_on_beat()
				_next_beat_time += 60.0 / bpm
	
	var progress = 1.0 - ((hit_time - _last_song_time) / travel_time)
	position = lerp(spawn_pos, hit_pos, progress)
	
	if position.x < screen_center.x * -8:
		_remove_from_conductor()
		queue_free()

func _on_beat() -> void:
	AudioHub.play_note_sfx()
	pass

func _exit_tree() -> void:
	_remove_from_conductor()
