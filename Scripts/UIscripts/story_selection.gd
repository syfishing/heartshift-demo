extends Node2D

@export var storypointindex: int = 0
@onready var storypointcount: int = $"2DStuff"/StoryPoints.get_child_count(storypointindex)
@onready var current_point: Node2D = $"2DStuff"/StoryPoints.get_child(storypointindex)
@onready var bg_normal_top_color: Color = %BG.material.get_shader_parameter("top_color")

var CoreStageScene: PackedScene = preload("res://Prefabs/Scenes/Story.tscn") # change later!!
var finalstagelock: int = 2

const FINAL_POINT_BG_TOP_COLOR: Color = Color("ff2b2f00")
const FINAL_POINT_CARD_MODULATE: Color = Color("ff5e5e")

var _bg_top_color_tween: Tween
var _card_modulate_tween: Tween

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
	if Save.stage > 3:
		finalstagelock = 1 #boss level unlock
		$"2DStuff/MainStoryLine".point_nodes.append($"2DStuff/StoryPoints/StoryPoint5")
	storypointindex = clamp(storypointindex,0,storypointcount-finalstagelock)
	current_point = $"2DStuff"/StoryPoints.get_child(storypointindex)
	$Camera2D.position.x = current_point.position.x
	$"2DStuff"/StoryPointCursor/Circle.position = current_point.position
	%CircleAnimationPlayer.stop()
	%CircleAnimationPlayer.play("CircleAnim")
	
	#Updating the Card
	var current_chart = current_point.chart
	var base_card_modulate: Color = %Card.modulate
	if is_locked(storypointindex):
		base_card_modulate = Color("666666")
		%SongName.text = "???"
		%Stage.text = ""
		%Difficulty.text = ""
		%Quote.text = '"Locked"'
		%SongCoverImage.texture = null
	elif current_chart:
		base_card_modulate = Color("ffffff")
		%SongName.text = current_chart.name
		%Stage.text = "Stage " + str(current_chart.stage)
		%Difficulty.text = "Diff. " + str(current_chart.difficulty)
		%Quote.text = '"' + current_point.story_quote + '"'
		%SongCoverImage.texture = current_chart.cover

		print(current_chart.id)
		if Save.ranks.has(current_chart.id):
			%Grade.get_parent().modulate = Color(1.0, 1.0, 1.0, 1.0)
			%Grade.text = Save.ranks[current_chart.id].rank
		else:
			%Grade.get_parent().modulate = Color(0.0, 0.0, 0.0, 0.0)

	update_final_point_effect(storypointindex == storypointcount - 1, base_card_modulate)

func update_final_point_effect(is_final: bool, normal_card_modulate: Color) -> void:
	%Card.material.set_shader_parameter("enabled", is_final)

	if _bg_top_color_tween and _bg_top_color_tween.is_valid():
		_bg_top_color_tween.kill()
	_bg_top_color_tween = create_tween()
	_bg_top_color_tween.tween_property(%BG.material, "shader_parameter/top_color", FINAL_POINT_BG_TOP_COLOR if is_final else bg_normal_top_color, 0.35)

	if _card_modulate_tween and _card_modulate_tween.is_valid():
		_card_modulate_tween.kill()
	_card_modulate_tween = create_tween()
	_card_modulate_tween.tween_property(%Card, "modulate", FINAL_POINT_CARD_MODULATE if is_final else normal_card_modulate, 0.35)

func is_locked(index: int) -> bool:
	return index > Save.stage

func select():
	if is_locked(storypointindex):
		return

	$LeavePlayer.play("SceneChange")


func _on_leave_player_animation_finished(anim_name: StringName) -> void:
	if current_point.story:
		var inst = CoreStageScene.instantiate()
		inst.story = current_point.story
		inst.chart = current_point.chart
		inst.origin_index = storypointindex

		if current_point.special_level:
			inst.special_level = current_point.special_level
			print("special level detected")
		if current_point.second_story:
			inst.second_story = current_point.second_story
			print("special story detected")

		AudioHub.stop_menu_music()
		# Defer the swap to the next frame
		call_deferred("_replace_scene", inst)
	else:
		#WRITE WHAT TO DO FOR NON STORY POINTS HERE
		pass



func _replace_scene(new_scene):
	await get_tree().process_frame  # wait one frame so the scene unlocks

	var tree := get_tree()

	tree.current_scene.free()
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene
