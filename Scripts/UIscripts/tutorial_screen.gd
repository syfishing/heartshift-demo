extends CanvasLayer

var stages := []
var current_stage := 0

# FirstStage lane checks
var lane_pressed := {
	"Lane1": false,
	"Lane2": false,
	"Lane3": false
}

func _ready() -> void:
	stages = [
		$Control/TextureRect/FirstStage,
		$Control/TextureRect/SecondStage,
		$Control/TextureRect/ThirdStage,
		$Control/TextureRect/FourthStage
	]
	%Pause.disabled = true
	_update_visibility()

func _process(delta: float) -> void:
	if current_stage == 0:
		_handle_first_stage_inputs()
	else:
		if Input.is_action_just_pressed("Select"):
			_next_stage()

func _handle_first_stage_inputs() -> void:
	if Input.is_action_just_pressed("lane1"):
		lane_pressed["Lane1"] = true
		$Control/TextureRect/FirstStage/TopCheck.self_modulate = Color("b36418")

	if Input.is_action_just_pressed("lane2"):
		lane_pressed["Lane2"] = true
		$Control/TextureRect/FirstStage/MiddleCheck.self_modulate = Color("b36418")

	if Input.is_action_just_pressed("lane3"):
		lane_pressed["Lane3"] = true
		$Control/TextureRect/FirstStage/BottomCheck.self_modulate = Color("b36418")

	if lane_pressed.values().count(true) == 3:
		_next_stage()
	

func _next_stage() -> void:
	current_stage += 1
	
	if current_stage >= stages.size():
		fade_out_and_finish()
		return
	
	_update_visibility()

func _update_visibility() -> void:
	for i in range(stages.size()):
		stages[i].visible = (i == current_stage)

func fade_out_and_finish() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property($Control, "modulate:a", 0.0, 0.8) # fade over 0.8 seconds
	tween.finished.connect(_on_fade_complete)
	
func _on_fade_complete() -> void:
	print("Fade complete!")
	$"..".start_level()
	%Pause.disabled = false
