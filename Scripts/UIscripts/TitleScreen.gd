extends Node2D

var started: bool = false

func _input(event: InputEvent) -> void:
	if started:
		return

	# Keyboard
	if event is InputEventKey and event.pressed and not event.echo:
		_start_game()
		return

	# Mouse buttons (left/right/middle)
	if event is InputEventMouseButton and event.pressed:
		_start_game()
		return

	# Gamepad buttons
	if event is InputEventJoypadButton and event.pressed:
		_start_game()
		return

func _start_game() -> void:
	started = true
	get_tree().change_scene_to_file("res://Prefabs/Scenes/MainMenu.tscn")
