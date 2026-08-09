extends Node

var bgmusicplayer: AudioStreamPlayer
var trackmusicplayer: AudioStreamPlayer
var menumusicplayer: AudioStreamPlayer
var sfxplayer: AudioStreamPlayer
var typingplayer: AudioStreamPlayer

var pause_state = false
var track_position = 0.0


func _ready():
	bgmusicplayer = get_node("BGMusicStreamPlayer")
	trackmusicplayer = get_node("TrackStreamPlayer")
	menumusicplayer = get_node("MainMenuMusicStreamPlayer")
	sfxplayer = get_node("SFXStreamPlayer")
	typingplayer = get_node("TypingPlayer")


func fade_volume(player: AudioStreamPlayer, from_db: float, to_db: float, duration: float) -> void:
	var tween := create_tween()
	player.volume_db = from_db
	tween.tween_property(player, "volume_db", to_db, duration)
	await tween.finished


func play_track(audio: AudioStream):
	trackmusicplayer.stream = audio
	trackmusicplayer.volume_db = -40
	trackmusicplayer.play()
	fade_volume(trackmusicplayer, -40, 0, 0.8)


func toggle_trackpause():
	if pause_state == false:
		track_position = trackmusicplayer.get_playback_position()
		await fade_volume(trackmusicplayer, trackmusicplayer.volume_db, -40, 0.5)
		trackmusicplayer.stop()
		pause_state = true
	else:
		trackmusicplayer.play(track_position)
		fade_volume(trackmusicplayer, -40, 0, 0.5)
		pause_state = false


func play_music(audio: AudioStream):
	bgmusicplayer.stream = audio
	bgmusicplayer.volume_db = -40
	bgmusicplayer.play()
	fade_volume(bgmusicplayer, -40, 0, 1.0)


func stop_music():
	await fade_volume(bgmusicplayer, bgmusicplayer.volume_db, -40, 0.7)
	bgmusicplayer.stop()


func play_menu_music(audio: AudioStream, stopping: bool):
	if menumusicplayer.stream == audio and menumusicplayer.playing and stopping == false:
		return

	if stopping == false:
		menumusicplayer.stream = audio
		menumusicplayer.volume_db = -40
		menumusicplayer.play()
		fade_volume(menumusicplayer, -40, 0, 1.0)
	else:
		await fade_volume(menumusicplayer, menumusicplayer.volume_db, -40, 0.7)
		menumusicplayer.stop()


func stop_menu_music():
	await fade_volume(menumusicplayer, menumusicplayer.volume_db, -40, 0.7)
	menumusicplayer.stop()


func play_note_sfx():
	sfxplayer.play()

func change_note_sfx(audio: AudioStream):
	sfxplayer.stream = audio

func start_typing():
	typingplayer.play()

func stop_typing():
	typingplayer.stop()
