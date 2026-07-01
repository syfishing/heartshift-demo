extends Node2D

const menu_theme = preload("res://Audio/Music/dreamcatcher.wav")
var storypointindex = 0

@onready var default_button = $CanvasLayer2/ButtonSelect/Story

func _ready() -> void:
	AudioHub.play_menu_music(menu_theme, false)
	default_button.grab_focus()

func _process(delta: float) -> void:
	if (Input.is_action_just_released("Exit")):
		get_tree().change_scene_to_file("res://Prefabs/Scenes/TitleScreen.tscn")
