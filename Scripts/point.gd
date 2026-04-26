extends Node2D

var hit = false

@export var speed: float = 100.0
var screen_center: Vector2
func _ready() -> void:
	screen_center = get_viewport_rect().size / 2.0
	pass

func _process(delta: float) -> void:
	position.x += speed * delta
	
	#Debug Code to be removed later
	if position.x < 257:
		$GPUParticles2D2.emitting = true
		$GPUParticles2D.emitting = true
	
	if position.x < screen_center.x*-4:
		queue_free()
	pass
