extends Node2D

@onready var audio_player = AudioHub.trackmusicplayer
@onready var anim_player = $EventPlayer

func _ready() -> void:
	anim_player.play("Event")

func _process(delta: float) -> void:
	var audio_t = audio_player.get_playback_position()
	var anim_t = anim_player.current_animation_position

	# Only correct if drift is noticeable
	if abs(audio_t - anim_t) > 0.01:  # 10ms threshold
		anim_player.seek(audio_t)
