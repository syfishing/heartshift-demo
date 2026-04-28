extends Node2D

# Variables down from Conductor
var hit_time: float = 0.0
var travel_time: float = 2.0
var spawn_pos: Vector2
var hit_pos: Vector2

@onready var screen_center = get_viewport_rect().size

# If its hit
var hit = false

var audio_player_ref: AudioStreamPlayer

func _remove_from_conductor() -> void:
	if get_parent().has_method("remove_active_note"):
		get_parent().remove_active_note(self )

func _process(_delta: float) -> void:
	if not audio_player_ref:
		return
		
	visible = true
	
	var song_time = audio_player_ref.get_playback_position() + AudioServer.get_time_since_last_mix()
	
	var progress = 1.0 - ((hit_time - song_time) / travel_time)
	
	position = lerp(spawn_pos, hit_pos, progress)
	
	if position.x < screen_center.x * -8:
		_remove_from_conductor()
		queue_free()

func _exit_tree() -> void:
	_remove_from_conductor()
