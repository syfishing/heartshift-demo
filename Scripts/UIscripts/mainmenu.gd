extends Node2D

const menu_theme = preload("res://Audio/Music/dreamcatcher.wav")
var storypointindex = 0

func _process(delta: float) -> void:
	if (Input.is_action_just_released("Exit")):
		get_tree().change_scene_to_file("res://Prefabs/Scenes/TitleScreen.tscn")
		
	if (Input.is_action_just_pressed("ui_up")):
		move_selection(-1)
		
	if (Input.is_action_just_pressed("ui_down")):
		move_selection(1)
	
	
func _on_rhythm_play_button_pressed() -> void:
	AudioHub.play_menu_music(menu_theme, true)
	get_tree().change_scene_to_file("res://Prefabs/Scenes/Demo.tscn")

func _on_story_select_button_pressed() -> void:
	AudioHub.play_menu_music(menu_theme, true)
	get_tree().change_scene_to_file("res://Prefabs/Scenes/StorySelection.tscn")
	pass # Replace with function body.

func _ready() -> void:
	AudioHub.play_menu_music(menu_theme, false)
	
func move_selection(index_change):
	$MenuPoints.get_child(storypointindex).buttonanimate.play("Deselected")
	storypointindex += index_change
	storypointindex = clamp(storypointindex,0,$MenuPoints.get_child_count()-2)
	$MenuPoints.get_child(storypointindex).buttonanimate.play("Selected")
	print(storypointindex)
	
	%Circle.position = $MenuPoints.get_child(storypointindex).position
	%CircleAnimationPlayer.play("CircleAnim")
	
	
	$Camera2D.position = Vector2(576, $MenuPoints.get_child(storypointindex).position.y)
	
	
	if storypointindex % 2:
		$StoryPointCursor/Circle/PointerLine.scale = Vector2(-1.754,1.754)
	else:
		$StoryPointCursor/Circle/PointerLine.scale = Vector2(1.754,1.754)
