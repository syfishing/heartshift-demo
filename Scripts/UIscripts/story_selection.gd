extends Node2D

@export var storypointindex: int = 2
@onready var storypointcount: int = $StoryPoints.get_child_count(storypointindex)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#arrow keys or lane buttons
	if Input.is_action_just_pressed("lane1"):
		storypointindex -= 1
		select()
	elif Input.is_action_just_pressed("lane3"):
		storypointindex += 1
		select()
	

	#storypointindex = clamp(storypointindex,0,storypointcount-1)
	#var current_point = $StoryPoints.get_child(storypointindex)
	#$Camera2D.position.x = current_point.position.x
	#$Circle.position = current_point.position
	##$Circle/ConnectLine.points = [Vector2(0,0), Vector2(0,lerp())]
	#%CircleAnimationPlayer.play("CircleAnim")

func _on_right_button_pressed() -> void:
	storypointindex += 1
	select()
	pass # Replace with function body.


func _on_left_button_pressed() -> void:
	storypointindex -= 1
	select()
	pass # Replace with function body.

func select():
	storypointindex = clamp(storypointindex,0,storypointcount-1)
	var current_point = $StoryPoints.get_child(storypointindex)
	$Camera2D.position.x = current_point.position.x
	$StoryPointCursor/Circle.position = current_point.position
	#$Circle/ConnectLine.points = [Vector2(0,0), Vector2(0,lerp())]
	%CircleAnimationPlayer.stop()
	%CircleAnimationPlayer.play("CircleAnim")
