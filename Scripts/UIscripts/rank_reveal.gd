extends Control

@export var reveal_at_end: bool = true
var close_reveal: bool = false
var score: float = 0
var rank: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioHub.trackmusicplayer.finished.connect(_on_music_finished)
	%ArtistLabel.text = $"../..".chart.artist_name
	%ChartingLabel.text = $"../..".chart.charter_name
	%SongCover.texture = $"../..".chart.cover
	

func _on_music_finished():
	print("Music ended!")
	
	if reveal_at_end:
		%RevealPlayer.play("RankReveal")
	


func _on_button_button_down() -> void:
	%RevealPlayer.play("RankRevealCrash")
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	# Keyboard
	if (event is InputEventKey and event.is_pressed() and not event.is_echo() and close_reveal):
		%RevealPlayer.play("CloseReveal")
		# change to whatever next scene needs to be

func _process(delta: float) -> void:
	#get per rank scores
	var rating_num = %PointManager.rating_num
	%DreamyScore.text = str(rating_num["Dreamy"])
	%GreatScore.text = str(rating_num["Great"])
	%GoodScore.text = str(rating_num["Good"])
	%PassScore.text = str(rating_num["Pass"])
	%FailScore.text = str(rating_num["Fail"])

	score = %PointManager.score
	$Reveal/Rank/Points.text = "(" + str(score) + "%)"
	if score >= 90:
		rank = "S"
	elif score >= 80:
		rank = "A"
	elif score >= 70:
		rank = "B"
	elif score >= 60:
		rank = "C"
	elif score >= 50:
		rank = "D"
	else:
		rank = "F"
	
	$Reveal/Rank/Grade.text = rank
	
	
func _on_reveal_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "RESET": return
	print("help")
	close_reveal = true
	if anim_name == "CloseReveal":
		print("left")
		if Save.ranks.has($"../..".chart.id):
			if score > Save.ranks[$"../..".chart.id].score:
				Save.ranks[$"../..".chart.id].score = score
				Save.ranks[$"../..".chart.id].rank = rank
		else:
			Save.ranks[$"../..".chart.id] = {
				"score": score,
				"rank": rank
			}
			if $"../..".from_story:
				Save.unlock_next_stage()
			
		if $"../..".second_story:
			var CoreStageScene: PackedScene = load("res://Prefabs/Scenes/Story.tscn")
			var inst = CoreStageScene.instantiate()
			inst.story = $"../..".second_story
			inst.chart = null

			# Defer the swap to the next frame
			call_deferred("_replace_scene", inst)
		else:
			get_tree().change_scene_to_file("res://Prefabs/Scenes/StorySelection.tscn")
	pass # Replace with function body.


func _replace_scene(new_scene):
	await get_tree().process_frame  # wait one frame so the scene unlocks

	var tree := get_tree()

	tree.current_scene.free()
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene
