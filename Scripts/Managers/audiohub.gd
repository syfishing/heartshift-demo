extends Node

@onready var musicplayer = $TrackStreamPlayer

func play_track(audio: AudioStream):
	$TrackStreamPlayer.play(audio)
	
func play_music(audio: AudioStream):
	$BGMusicStreamPlayer.play(audio)

func play_menu_music(audio: AudioStream, stopping: bool):
	if $MainMenuMusicStreamPlayer.stream == audio && stopping == false:
		return
	if stopping == false:
		$MainMenuMusicStreamPlayer.stream = audio
		$MainMenuMusicStreamPlayer.play()
	else:
		$MainMenuMusicStreamPlayer.stop()

func play_note_sfx() -> void:
	$SFXStreamPlayer.play()
	
func change_note_sfx(audio: AudioStream) -> void:
	$SFXStreamPlayer.stream = audio
