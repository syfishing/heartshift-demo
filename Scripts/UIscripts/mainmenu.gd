extends Node2D

const menu_theme = preload("res://Audio/Music/dreamcatcher.wav")

func _on_rhythm_play_button_pressed() -> void:
	AudioHub.play_menu_music(menu_theme, true)
	get_tree().change_scene_to_file("res://Prefabs/Scenes/Demo.tscn")

func _ready() -> void:
	AudioHub.play_menu_music(menu_theme, false)
