extends Node

@onready var trackmusicplayer = $TrackStreamPlayer

func play_track(audio: AudioStream):
	$TrackStreamPlayer.stream = audio
	$TrackStreamPlayer.play()
	
func play_music(audio: AudioStream):
	$BGMusicStreamPlayer.stream = audio
	$BGMusicStreamPlayer.play()

func stop_music():
	$BGMusicStreamPlayer.stop()

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
