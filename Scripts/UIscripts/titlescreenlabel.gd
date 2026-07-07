extends RichTextLabel

var isAnimated = false

func _process(delta: float) -> void:
	#if (MainMenuBGTimer.activateEffects == true):
		#if (isAnimated == false):
			#text = "[wave amp=100.0 freq=2.5 connected=1]HEARTSHIFT[/wave]"
			#isAnimated = true
		#else:
			#return
	pass
