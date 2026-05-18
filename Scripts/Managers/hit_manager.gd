extends Node

var combo: int = 0
var scorenum: float = 0
var rating_score: Dictionary = {"Dreamy": 1, "Great": 0.8, "Good": 0.6, "Pass": 0.4}

@onready var chart_size = $"../Conductor".chart.notes.size()

func _on_hit_line_rating_broadcast(rating: String, _lane: String) -> void:
	print(rating)
	
	%RatingLabel.text = rating+"!"
	%RatingAnimPlayer.play("RatingAnim")

	if rating == "Fail":
		combo = 0
		%ComboLabel.text = str(combo)
	else:
		#Combo
		combo += 1
		%ComboLabel.text = str(combo)
		
		if rating != "Hold":
			scorenum += rating_score[rating]
			
	
	#Accuracy
	var score = snapped((scorenum/chart_size)*100, 0.0001)
	%AccuracyLabel.text = str(score) + "%"
	
	camera_tilt(_lane)
	pass # Replace with function body.
	
func _ready() -> void:
	pass
#redundant code but just in case anybody wants the camera to rotate on hits
#Note: it looks horrible so don't even think about wasting another hour on it dumbass
func camera_tilt(lane):
	#if lane == "lane1":
		#$"../Camera2D".rotation = -0.01
	#elif lane == "lane2":
		#$"../Camera2D".rotation = 0
	#else:
		#$"../Camera2D".rotation = 0.01
	pass
