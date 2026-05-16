extends Node

@onready var musicplayer = $TrackStreamPlayer

func play_track(audio: AudioStream):
	$TrackStreamPlayer.play(audio)
	
func play_music(audio: AudioStream):
	$MusicStreamPlayer.play(audio)

func play_note_sfx() -> void:
	$SFXStreamPlayer.play()
	
func change_note_sfx(audio: AudioStream) -> void:
	$SFXStreamPlayer.stream = audio
