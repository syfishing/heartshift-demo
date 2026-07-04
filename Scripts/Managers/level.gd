extends Node2D

@export var chart: ChartData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioHub.stop_music()
	AudioHub.stop_menu_music()
	AudioHub.play_track(chart.audio)
	$Conductor.chart = chart
	%SongLabel.text = chart.name
	%DetailLabel.text = "Stage " + str(chart.stage) + " - Diff. " + str(chart.difficulty)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
