extends Control

@export var reveal_at_end: bool = true
var close_reveal: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	AudioHub.trackmusicplayer.finished.connect(_on_music_finished)
	%ArtistLabel.text = $"../..".chart.artist_name
	%ChartingLabel.text = $"../..".chart.charter_name
	%SongCover.texture = $"../..".chart.cover

func _on_music_finished():
	print("Music ended!")
	
	if reveal_at_end:
		$RevealPlayer.play("RankReveal")
	


func _on_button_button_down() -> void:
	$RevealPlayer.play("RankRevealCrash")
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	# Keyboard
	if (event is InputEventKey and event.is_pressed() and not event.is_echo() and close_reveal):
		$RevealPlayer.play("CloseReveal")
		# change to whatever next scene needs to be

func _process(delta: float) -> void:
	#get per rank scores
	var rating_num = %PointManager.rating_num
	%DreamyScore.text = str(rating_num["Dreamy"])
	%GreatScore.text = str(rating_num["Great"])
	%GoodScore.text = str(rating_num["Good"])
	%PassScore.text = str(rating_num["Pass"])
	%FailScore.text = str(rating_num["Fail"])

	var score = %PointManager.score
	if score >= 90:
		$Reveal/Rank/Grade.text = "S"
	elif score >= 80:
		$Reveal/Rank/Grade.text = "A"
	elif score >= 70:
		$Reveal/Rank/Grade.text = "B"
	elif score >= 60:
		$Reveal/Rank/Grade.text = "C"
	elif score >= 50:
		$Reveal/Rank/Grade.text = "D"
	else:
		$Reveal/Rank/Grade.text = "F"

func _on_reveal_player_animation_finished(anim_name: StringName) -> void:
	close_reveal = true
	pass # Replace with function body.
