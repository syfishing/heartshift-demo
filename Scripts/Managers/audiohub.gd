extends Node

var bgmusicplayer: AudioStreamPlayer
var trackmusicplayer: AudioStreamPlayer
var menumusicplayer: AudioStreamPlayer
var sfxplayer: AudioStreamPlayer
var typingplayer: AudioStreamPlayer

var pause_state = false
var track_position = 0.0

var _track_anchor_position = 0.0
var _track_anchor_time = 0

var _resume_pending = false


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
	if _fade_tweens.has(player):
		var old_tween: Tween = _fade_tweens[player]
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween = create_tween()
	_fade_tweens[player] = tween
	player.volume_db = from_db
	tween.tween_property(player, "volume_db", to_db, duration)
	await tween.finished


func play_track(audio: AudioStream):
	track_position = 0.0
	trackmusicplayer.stream = audio
	trackmusicplayer.volume_db = -60

	if pause_state:
		_resume_pending = true
		return

	_resume_pending = false
	_start_track_at(0.0)
	fade_volume(trackmusicplayer, -60, music_volume, 0.8)


func clear_pause_state() -> void:
	pause_state = false
	_resume_pending = false


func _start_track_at(position: float) -> void:
	_track_anchor_position = position
	_track_anchor_time = Time.get_ticks_usec()
	trackmusicplayer.play(position)


func _current_track_position() -> float:
	var reported = trackmusicplayer.get_playback_position()
	if reported < _track_anchor_position:
		return _track_anchor_position + (Time.get_ticks_usec() - _track_anchor_time) / 1000000.0

	return reported + AudioServer.get_time_since_last_mix()


func toggle_trackpause() -> void:
	if pause_state == false:
		pause_state = true
		if trackmusicplayer.playing:
			track_position = _current_track_position()
			_resume_pending = true
			trackmusicplayer.stop()
			fade_volume(trackmusicplayer, trackmusicplayer.volume_db, -60, 0.5)
	else:
		pause_state = false
		if not _resume_pending:
			return

		_resume_pending = false
		var length = _track_length()
		if length > 0.0:
			track_position = minf(track_position, length)
		_start_track_at(track_position)
		fade_volume(trackmusicplayer, -60, music_volume, 0.5)


func _track_length() -> float:
	if trackmusicplayer.stream == null:
		return 0.0
	return trackmusicplayer.stream.get_length()

func stop_track():
	trackmusicplayer.stop()
	pause_state = false
	_resume_pending = false
	track_position = 0.0
	_track_anchor_position = 0.0
	_track_anchor_time = 0



func play_music(audio: AudioStream):
	bgmusicplayer.stream = audio
	bgmusicplayer.volume_db = 60
	bgmusicplayer.play()
	fade_volume(bgmusicplayer, -60, music_volume, 1.0)


func stop_music():
	await fade_volume(bgmusicplayer, bgmusicplayer.volume_db, -60, 0.7)
	bgmusicplayer.stop()


func play_menu_music(audio: AudioStream, stopping: bool):
	if menumusicplayer.stream == audio and menumusicplayer.playing and stopping == false:
		return

	if stopping == false:
		menumusicplayer.stream = audio
		menumusicplayer.volume_db = -60
		menumusicplayer.play()
		fade_volume(menumusicplayer, -60, music_volume, 1.0)
	else:
		await fade_volume(menumusicplayer, menumusicplayer.volume_db, -60, 0.7)
		menumusicplayer.stop()


func stop_menu_music():
	await fade_volume(menumusicplayer, menumusicplayer.volume_db, -60, 0.7)
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
		$TrackStreamPlayer.volume_db = music_volume

	else:
		return
