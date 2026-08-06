extends Node2D

@export var story: StoryData:
	set(value):
		story = value
		if _initialized:
			_event_idx = 0
			_setup_story()

@export var chart: ChartData

var scene: PackedScene = preload("res://Prefabs/Scenes/Level.tscn") # change later!!



var _initialized := false
var _event_idx := 0
var _character_nodes: Dictionary[String, Sprite2D] = {}

var _dialogue_tween: Tween

signal _key_pressed


func _find_character(id: String) -> CharacterData:
	for c in story.characters:
		if c.id == id:
			return c
	
	var c = CharacterData.new()
	c.id = id
	return c


func _ready() -> void:
	if story:
		print(chart)
		_setup_story()
	pass


func _setup_story() -> void:
	for v in _character_nodes.values():
		v.queue_free()
	_character_nodes.clear()
	
	var height := get_viewport().get_visible_rect().size.y
	
	for c in story.characters:
		var node = Sprite2D.new()
		var sprite := c.poses[c.default_pose]
		node.texture = sprite
		node.centered = false
		node.offset = Vector2(0, -sprite.get_height())
		node.position = Vector2(10000, height)
		add_child(node)
		_character_nodes[c.id] = node
	
	_play_event()


func _play_event() -> void:
	print("playing event ", _event_idx)
	
	if _event_idx >= story.events.size():
		#get_tree().change_scene_to_file("res://Prefabs/Scenes/StorySelection.tscn")
		$TransitionPlayer.play("Exit_Transition")
		return
	
	var event := story.events[_event_idx]
	if event is StoryDialogueEvent:
		var c = _find_character(event.character_id)
		
		%Dialogue.show()
		%TextLabel.visible_ratio = 0.0
		%TextLabel.text = event.text
		%SpeakerLabel.text = c.name
		%SpeakerLabel.add_theme_color_override("font_color", c.color)
		AudioHub.start_typing()
		
		# TODO: filter out bbcode etc for better timing
		var typing_time = event.text.length() / 40.0 / event.typing_speed
		_dialogue_tween = create_tween()
		_dialogue_tween.tween_property(%TextLabel, "visible_ratio", 1.0, typing_time).from(0.0)
		_dialogue_tween.finished.connect(func(): _finish_typing(event.auto_advance))
		if not event.uninterruptible:
			_key_pressed.connect(func(): _finish_typing(event.auto_advance), CONNECT_ONE_SHOT)
	elif event is StoryBGEvent:
		%Background.texture = event.background
		%Background.show()
		%BackgroundV.stop()
		%BackgroundV.hide()
		_next_event()
	elif event is StoryCutsceneEvent:
		%BackgroundV.stream = event.video
		%BackgroundV.loop = event.repeat
		%BackgroundV.volume = 0.0 if event.mute else 1.0
		%BackgroundV.show()
		%BackgroundV.play()
		%Background.hide()
		if event.wait_until_finish:
			%BackgroundV.finished.connect(_next_event, CONNECT_ONE_SHOT)
		else:
			_next_event()
	elif event is StoryMoveEvent:
		var node := _character_nodes[event.character_id]
		if node:
			node.flip_h = event.is_flipped
			if node.position.x >= 9999:
				node.position.x = event.x_pos
			else:
				var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
				tween.tween_property(node, "position:x", event.x_pos, event.duration)
		_next_event()
	elif event is StoryDelayEvent:
		get_tree().create_timer(event.time_seconds).timeout.connect(_next_event)
	elif event is StoryMusicEvent:
		AudioHub.play_music(event.audio)
		_next_event()
	elif event is StoryPoseEvent:
		var ch := _find_character(event.character_id)
		if ch:
			var sprite := ch.poses[event.pose]
			var node := _character_nodes[event.character_id]
			node.texture = sprite
			node.offset = Vector2(0, -sprite.get_height())
		_next_event()


func _next_event() -> void:
	if _key_pressed.is_connected(_next_event):
		_key_pressed.disconnect(_next_event)
	_event_idx += 1
	call_deferred("_play_event")


## call to show all text and wait for user input before continue
func _finish_typing(auto_advance: bool) -> void:
	AudioHub.stop_typing()
	if _key_pressed.is_connected(_finish_typing):
		_key_pressed.disconnect(_finish_typing)
	if _dialogue_tween:
		_dialogue_tween.stop()
	%TextLabel.visible_ratio = 1.0
	if auto_advance:
		_next_event()
	else:
		_key_pressed.connect(_next_event, CONNECT_ONE_SHOT)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed():
		_key_pressed.emit()


func _on_transition_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "Exit_Transition": return
	
	var inst = scene.instantiate()
	#inst.story = story
	inst.chart = chart
	AudioHub.stop_menu_music()
	# Defer the swap to the next frame
	call_deferred("_replace_scene", inst)



func _replace_scene(new_scene):
	await get_tree().process_frame  # wait one frame so the scene unlocks

	var tree := get_tree()

	tree.current_scene.free()
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene
