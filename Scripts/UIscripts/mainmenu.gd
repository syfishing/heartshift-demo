extends Node2D

const menu_theme = preload("res://Audio/Music/dreamcatcher.wav")
var storypointindex = 0
var menu_to_change : String

@onready var default_button = $CanvasLayer2/ButtonSelect/Story

func _ready() -> void:
	AudioHub.play_menu_music(menu_theme, false)
	default_button.grab_focus()

func _process(delta: float) -> void:
	if (Input.is_action_just_released("Exit")):
		get_tree().change_scene_to_file("res://Prefabs/Scenes/TitleScreen.tscn")




func _on_story_button_down() -> void:
	menu_to_change = "StorySelection"
	pass # Replace with function body.


func _on_rhythm_play_button_down() -> void:
	menu_to_change = "RhythmPlay"
	pass # Replace with function body.


func _on_options_button_down() -> void:
	menu_to_change = "TitleScreen" # WE DON'T GOT NO OPTIONS MENU PEOPLE YAYYYY
	pass # Replace with function body.


func _on_transition_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://Prefabs/Scenes/" + menu_to_change + ".tscn")
	print("anim done")
	pass # Replace with function body.
