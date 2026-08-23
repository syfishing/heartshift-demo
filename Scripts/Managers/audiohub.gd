extends Node

var bgmusicplayer: AudioStreamPlayer
var trackmusicplayer: AudioStreamPlayer
var menumusicplayer: AudioStreamPlayer
var sfxplayer: AudioStreamPlayer
var typingplayer: AudioStreamPlayer

var pause_state = false
var track_position = 0.0


var save_path = "user://options.save"

var sfx_volume = 0.0
var music_volume = 0.0
var note_speed = 50.0

var _fade_tweens: Dictionary = {}

func _enter_tree() -> void:
	pass

func _ready():
	bgmusicplayer = $BGMusicStreamPlayer
	trackmusicplayer = $TrackStreamPlayer
	menumusicplayer = $MainMenuMusicStreamPlayer
	sfxplayer = $SFXStreamPlayer
	typingplayer = $TypingPlayer
	load_data()


func fade_volume(player: AudioStreamPlayer, from_db: float, to_db: float, duration: float) -> void:
	# Cancel any fade already running on this player so rapid, repeated
	# calls (e.g. fast scrolling through a song list) can't pile up and
	# fire their delayed .play()/.stop() out of order.
	if _fade_tweens.has(player):
		var old_tween: Tween = _fade_tweens[player]
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween := create_tween()
	_fade_tweens[player] = tween
	player.volume_db = from_db
	tween.tween_property(player, "volume_db", to_db, duration)
	await tween.finished


func play_track(audio: AudioStream):
	trackmusicplayer.stream = audio
	trackmusicplayer.volume_db = -40
	trackmusicplayer.play()
	fade_volume(trackmusicplayer, -40, music_volume, 0.8)


func toggle_trackpause():
	if pause_state == false:
		track_position = trackmusicplayer.get_playback_position()
		trackmusicplayer.stop()
		await fade_volume(trackmusicplayer, trackmusicplayer.volume_db, -40, 0.5)
		pause_state = true
	else:
		
		await fade_volume(trackmusicplayer, -40, music_volume, 0.5)
		trackmusicplayer.play(track_position)
		pause_state = false

func stop_track():
	trackmusicplayer.stop()
	pause_state = false
	track_position = 0.0



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
		fade_volume(menumusicplayer, -40, music_volume, 1.0)
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


func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)

		sfx_volume = file.get_var()
		music_volume = file.get_var()

		file.get_var(true) # first_lane (unused here, but must be read to stay in sync with options.gd)
		file.get_var(true) # second_lane
		file.get_var(true) # third_lane
		file.get_var(true) # select

		note_speed = file.get_var()
		$SFXStreamPlayer.volume_db = sfx_volume
		$TypingPlayer.volume_db = sfx_volume

		$TypingPlayer.volume_db = sfx_volume
		$BGMusicStreamPlayer.volume_db = music_volume
		$MainMenuMusicStreamPlayer.volume_db = music_volume

	else:
		return
