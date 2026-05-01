extends Camera2D

@export var rotation_return_speed: float = 8.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation = lerp_angle(rotation, 0.0, clamp(delta * rotation_return_speed, 0.0, 1.0))
	pass
