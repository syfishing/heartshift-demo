extends Node2D

@export var story: StoryData:
	set(value):
		story = value
		if _initialized:
			_event_idx = 0
			_setup_story()

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
		_setup_story()


func _setup_story() -> void:
	for v in _character_nodes.values():
		v.queue_free()
	_character_nodes.clear()
	
	var height := get_viewport().get_visible_rect().size.y
	
	for c in story.characters:
		var node = Sprite2D.new()
		node.texture = c.sprite
		node.centered = false
		node.offset = Vector2(0, -c.sprite.get_height())
		node.position = Vector2(10000, height)
		add_child(node)
		_character_nodes[c.id] = node
	
	_play_event()


func _play_event() -> void:
	print("playing event ", _event_idx)
	
	if _event_idx >= story.events.size():
		get_tree().change_scene_to_file("res://Prefabs/Scenes/StorySelection.tscn")
		return
	
	var event := story.events[_event_idx]
	if event is StoryDialogueEvent:
		var c = _find_character(event.character_id)
		
		%Dialogue.show()
		%TextLabel.text = event.text
		%SpeakerLabel.text = c.name
		%SpeakerLabel.add_theme_color_override("font_color", c.color)
		
		# TODO: filter out bbcode etc for better timing
		var typing_time = event.text.length() / 40.0 / event.typing_speed
		_dialogue_tween = create_tween()
		_dialogue_tween.tween_property(%TextLabel, "visible_ratio", 1.0, typing_time).from(0.0)
		_dialogue_tween.finished.connect(func(): _finish_typing(event.auto_advance))
		if not event.uninterruptible:
			_key_pressed.connect(func(): _finish_typing(event.auto_advance), CONNECT_ONE_SHOT)
	elif event is StoryBGEvent:
		%Background.texture = event.background
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


func _next_event() -> void:
	if _key_pressed.is_connected(_next_event):
		_key_pressed.disconnect(_next_event)
	_event_idx += 1
	call_deferred("_play_event")


## call to show all text and wait for user input before continue
func _finish_typing(auto_advance: bool) -> void:
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
