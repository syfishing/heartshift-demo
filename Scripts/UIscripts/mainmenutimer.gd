extends Node2D

@export var current_stream: VideoStream
@export var current_numberline_pos = 0.0
const wavybg1 = preload("res://Assets/Backgrounds/wavymenubg1.ogv")
const wavybg2 = preload("res://Assets/Backgrounds/wavymenubg2.ogv")
var activateEffects = false

func _on_timeout() -> void:
	activateEffects = true
	$Timer.wait_time = 1.6/2
	print($Timer.wait_time/2)
	if (current_stream == wavybg1):
		current_stream = wavybg2
		
	elif (current_stream == wavybg2):
		current_stream = wavybg1
	
	
	if (current_numberline_pos + 30.88) >= 123.25:
		current_numberline_pos = 30.88
	else:
		current_numberline_pos += 30.88
		print(current_numberline_pos)
