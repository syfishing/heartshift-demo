extends Node2D

@export var storypointindex: int = 2
@onready var storypointcount: int = $"2DStuff"/StoryPoints.get_child_count(storypointindex)
@onready var current_point: Node2D = $"2DStuff"/StoryPoints.get_child(storypointindex)
var CoreStageScene: PackedScene = preload("res://Prefabs/Scenes/Demo.tscn") # change later!!

func _ready() -> void:
	change_selection() # just for making sure it updates the text at first

func _process(delta: float) -> void:
	#arrow keys or lane buttons
	if Input.is_action_just_pressed("lane1"):
		storypointindex -= 1
		change_selection()
	elif Input.is_action_just_pressed("lane3"):
		storypointindex += 1
		change_selection()
	elif Input.is_action_just_pressed("Select"):
		select()
		
	if (Input.is_action_just_released("Exit")):
		get_tree().change_scene_to_file("res://Prefabs/Scenes/MainMenu.tscn")
	

	#storypointindex = clamp(storypointindex,0,storypointcount-1)
	#var current_point = $StoryPoints.get_child(storypointindex)
	#$Camera2D.position.x = current_point.position.x
	#$Circle.position = current_point.position
	##$Circle/ConnectLine.points = [Vector2(0,0), Vector2(0,lerp())]
	#%CircleAnimationPlayer.play("CircleAnim")

func _on_right_button_pressed() -> void:
	storypointindex += 1
	change_selection()
	pass # Replace with function body.


func _on_left_button_pressed() -> void:
	storypointindex -= 1
	change_selection()
	pass # Replace with function body.

func change_selection():
	storypointindex = clamp(storypointindex,0,storypointcount-1)
	current_point = $"2DStuff"/StoryPoints.get_child(storypointindex)
	$Camera2D.position.x = current_point.position.x
	$"2DStuff"/StoryPointCursor/Circle.position = current_point.position
	%CircleAnimationPlayer.stop()
	%CircleAnimationPlayer.play("CircleAnim")
	
	#Updating the Card
	var current_chart = current_point.chart
	if current_chart:
		%SongName.text = current_chart.name
		%Stage.text = "Stage " + str(current_chart.stage)
		%Difficulty.text = "Diff. " + str(current_chart.difficulty)
		%Quote.text = '"' + current_point.story_quote + '"'
		
		%SongCoverImage.texture = current_chart.cover

func select():
	
	
	$LeavePlayer.play("SceneChange")


func _on_leave_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_packed(CoreStageScene)
	pass # Replace with function body.
