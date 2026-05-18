extends Node2D

@export var current_stream: VideoStream
const wavybg1 = preload("res://Assets/Backgrounds/wavymenubg1.ogv")
const wavybg2 = preload("res://Assets/Backgrounds/glitchymenubg1.ogv")
var activateEffects = false

func _on_timeout() -> void:
	activateEffects = true
	$Timer.wait_time = 1.6
	print($Timer.wait_time)
	if (current_stream == wavybg1):
		current_stream = wavybg2
	elif (current_stream == wavybg2):
		current_stream = wavybg1
