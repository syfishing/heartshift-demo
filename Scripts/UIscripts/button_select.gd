extends Control

func _on_story_button_down() -> void:
	transitionout()
	pass # Replace with function body.


func _on_rhythm_play_button_down() -> void:
	transitionout()
	pass # Replace with function body.


func _on_options_button_down() -> void:
	transitionout()
	pass # Replace with function body.


func transitionout() -> void:
	%Transition.visible = true
	%TransitionPlayer.play("TransitionOut")
