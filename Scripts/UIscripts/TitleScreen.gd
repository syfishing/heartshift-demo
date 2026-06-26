extends Node2D

var started: bool = false

const menu_theme = preload("res://Audio/Music/dreamcatcher.wav")

func _input(event: InputEvent) -> void:
	# Keyboard
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if (event.is_action_pressed("Exit")):
			get_tree().quit()
		else:
			_start_game()

	# Mouse buttons (left/right/middle)
	if event is InputEventMouseButton and event.pressed:
		_start_game()

	# Gamepad buttons
	if event is InputEventJoypadButton and event.pressed:
		_start_game()
		
func _start_game() -> void:
	get_tree().change_scene_to_file("res://Prefabs/Scenes/MainMenu.tscn")

func _ready() -> void:
	AudioHub.play_menu_music(menu_theme, false)

func _enter_tree() -> void:
	AudioHub.stop_music()
	if AudioHub.get_node("MainMenuMusicStreamPlayer").playing == false:
		AudioHub.play_menu_music(menu_theme, false)
