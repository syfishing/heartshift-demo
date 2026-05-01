extends Node

var combo: int = 0

func _on_hit_line_rating_broadcast(rating: String, _lane: String) -> void:
	print(rating)
	%RatingLabel.text = rating
	%RatingAnimPlayer.play("RatingAnim")

	if rating == "Fail":
		combo = 0
	else:
		combo += 1
		
	%ComboLabel.text = str(combo)
	camera_tilt(_lane)
	pass # Replace with function body.


func camera_tilt(lane):
	#if lane == "lane1":
		#$"../Camera2D".rotation = -0.01
	#elif lane == "lane2":
		#$"../Camera2D".rotation = 0
	#else:
		#$"../Camera2D".rotation = 0.01
	pass
