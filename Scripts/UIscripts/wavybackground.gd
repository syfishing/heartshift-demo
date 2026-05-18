extends VideoStreamPlayer

const wavybg1 = preload("res://Assets/Backgrounds/wavymenubg1.ogv")
const wavybg2 = preload("res://Assets/Backgrounds/glitchymenubg1.ogv")

func _process(delta: float) -> void:
	if (MainMenuBGTimer.current_stream != stream):
		stop()
		stream = MainMenuBGTimer.current_stream
		play()
