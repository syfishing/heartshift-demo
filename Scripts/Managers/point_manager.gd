extends Node

var combo: int = 0

func _on_hit_line_rating_broadcast(rating: String) -> void:
	print(rating)
	%RatingLabel.text = rating
	%RatingAnimPlayer.play("RatingAnim")

	if rating == "Fail":
		combo = 0
	else:
		combo += 1
	%ComboLabel.text = str(combo)
	pass # Replace with function body.
