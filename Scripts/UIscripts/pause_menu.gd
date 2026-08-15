extends CanvasLayer

var menu_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InputBlock.mouse_filter = Control.MOUSE_FILTER_STOP
	%DummyButton.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_released("Exit") and menu_open == false):
		openmenu()
		
	pass


func openmenu() -> void:
	$InputBlock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioHub.toggle_trackpause()
	%Stars.speed_scale = 0
	$AnimationPlayer.play("MenuOpen")
	menu_open = true
	$Button/ResumeLevel.grab_focus()


func _on_exit_level_pressed() -> void:
	AudioHub.stop_track()
	transitionout()


func _on_resume_level_pressed() -> void:
	$InputBlock.mouse_filter = Control.MOUSE_FILTER_STOP
	AudioHub.toggle_trackpause()
	%Stars.speed_scale = 1
	$AnimationPlayer.play("MenuClose")
	menu_open = false
	%Pause.disabled = false
	%DummyButton.grab_focus()
	
func transitionout() -> void:
	#%Transition.visible = true
	#%TransitionPlayer.play("TransitionOut")
	
	%RevealPlayer.play("CloseReveal")
	$AnimationPlayer.play("MenuClose")
	pass


func _on_pause_pressed() -> void:
	openmenu()
	%Pause.disabled = true
	pass # Replace with function body.
