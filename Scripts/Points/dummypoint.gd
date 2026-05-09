extends Node2D

var travel_time: float = 5.0
var spawn_pos: Vector2
var hit_pos: Vector2

@onready var screen_center = get_viewport_rect().size

var elapsed: float = 0.0

func _remove_from_conductor() -> void:
	if get_parent().has_method("remove_active_note"):
		get_parent().remove_active_note(self )


func _ready() -> void:
	position = spawn_pos

func _process(delta: float) -> void:
	elapsed += delta
	var progress = elapsed / travel_time
	position = lerp(spawn_pos, hit_pos, progress)
	
	if position.x < screen_center.x * -8:
		_remove_from_conductor()
		queue_free()

func _exit_tree() -> void:
	_remove_from_conductor()
