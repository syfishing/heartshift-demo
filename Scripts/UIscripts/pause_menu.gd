extends CanvasLayer

var menu_open: bool = false
var closing: bool = false

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

	if menu_open:
		return

	menu_open = true
	%Pause.disabled = true
	$InputBlock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioHub.toggle_trackpause()
	
	if %Stars: 
		%Stars.speed_scale = 0
	
	$AnimationPlayer.play("MenuOpen")
	$Button/ResumeLevel.grab_focus()


func _on_exit_level_pressed() -> void:
	AudioHub.stop_track()
	transitionout()


func _on_resume_level_pressed() -> void:
	if not menu_open or closing:
		return

	closing = true
	$InputBlock.mouse_filter = Control.MOUSE_FILTER_STOP
	$AnimationPlayer.play("MenuClose")
	
func transitionout() -> void:
	#%Transition.visible = true
	#%TransitionPlayer.play("TransitionOut")
	if %RevealPlayer:
		%RevealPlayer.play("CloseReveal")
	elif %TransitionPlayer:
		%TransitionPlayer.play("Exit_Transition_Menu")
	$AnimationPlayer.play("MenuClose")
	pass


func _on_pause_pressed() -> void:
	openmenu()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "MenuClose":
		menu_open = false
		closing = false
		AudioHub.toggle_trackpause()
	
		if %Stars: %Stars.speed_scale = 1
		
		%Pause.disabled = false
		%DummyButton.grab_focus()
	pass # Replace with function body.
