extends Node2D

const menu_theme = preload("res://Audio/Music/dreamcatcher.wav")

func _ready() -> void:
	AudioHub.play_menu_music(menu_theme, false)

func _enter_tree() -> void:
	AudioHub.stop_music()
	if AudioHub.get_node("MainMenuMusicStreamPlayer").playing == false:
		AudioHub.play_menu_music(menu_theme, false)

func _process(delta: float) -> void:
	if (Input.is_action_just_released("Exit")):
		get_tree().change_scene_to_file("res://Prefabs/Scenes/TitleScreen.tscn")

func _on_rhythm_play_button_pressed() -> void:
	AudioHub.play_menu_music(menu_theme, true)
	get_tree().change_scene_to_file("res://Prefabs/Scenes/RhythmPlay.tscn")

func _on_story_select_button_pressed() -> void:
	AudioHub.play_menu_music(menu_theme, true)
	get_tree().change_scene_to_file("res://Prefabs/Scenes/StorySelection.tscn")
	pass
