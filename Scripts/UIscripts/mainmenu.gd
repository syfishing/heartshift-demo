extends Node2D

const menu_theme = preload("res://Audio/Music/dreamcatcher.wav")

func _process(delta: float) -> void:
	if (Input.is_action_just_released("Exit")):
		get_tree().change_scene_to_file("res://Prefabs/Scenes/TitleScreen.tscn")

func _on_rhythm_play_button_pressed() -> void:
	AudioHub.play_menu_music(menu_theme, true)
	get_tree().change_scene_to_file("res://Prefabs/Scenes/Demo.tscn")

func _on_story_select_button_pressed() -> void:
	AudioHub.play_menu_music(menu_theme, true)
	get_tree().change_scene_to_file("res://Prefabs/Scenes/StorySelection.tscn")
	pass # Replace with function body.

func _ready() -> void:
	AudioHub.play_menu_music(menu_theme, false)
