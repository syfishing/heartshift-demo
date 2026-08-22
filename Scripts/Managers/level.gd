extends Node2D

@export var second_story: StoryData
@export var chart: ChartData
@export var start_delay: float = 0.0
@export var start_immediate: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioHub.stop_music()
	AudioHub.stop_menu_music()
	if get_node("%IntroPlayer"):
		%IntroPlayer.play("Intro")
	
	if start_immediate == false: return
	
	start_level()
	
	pass # Replace with function body.


func start_level():
	%Stars.emitting = true
	$Conductor.chart = chart
	%SongLabel.text = chart.name
	%DetailLabel.text = "Stage " + str(chart.stage) + " - Diff. " + str(chart.difficulty)
	
	await get_tree().create_timer(start_delay).timeout
	
	AudioHub.play_track(chart.audio)
