extends Node2D

@export var speed: float = 100.0
var screen_center: Vector2
func _ready() -> void:
	screen_center = get_viewport_rect().size / 2.0
	pass

func _process(delta: float) -> void:
	position.x += speed * delta
	
	if position.x < screen_center.x*-4:
		queue_free()
	pass
