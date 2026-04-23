extends Node2D

@export var speed: float = 100.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	position.y += speed * delta
	pass
