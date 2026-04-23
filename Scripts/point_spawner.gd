extends Node2D

@export var point_scene: PackedScene

@export var amplitude: float = 200.0
@export var frequency: float = 1.0
@export var curve_line: Line2D
# @export var line_color: Color = Color(0.2, 0.9, 1.0, 1.0) # I decided it'd be better to set this in the Line2D node instead
@export var line_width: float = 2.0
@export var handle_strength: float = 0.25
@export var bezier_steps_per_segment: int = 16

var time: float = 0.0
var screen_center: Vector2

var prev_x: float = 0.0
var last_x: float = 0.0
var sample_count: int = 0

var spawned_points: Array[Node2D] = []

func _ready() -> void:
	screen_center = get_viewport_rect().size / 2.0
	position.x = screen_center.x
	position.y = - screen_center.y * 4.0
	prev_x = position.x
	last_x = position.x
	sample_count = 1

func _process(delta: float) -> void:
	time += delta
	position.x = curve_formula(time)

	if sample_count >= 2:
		if is_peaking(prev_x, last_x, position.x):
			spawn_point_at_x(last_x)

	prev_x = last_x
	last_x = position.x
	sample_count += 1

	queue_redraw()

func _draw() -> void:
	if spawned_points.size() < 2:
		return

	var valid_points: Array[Node2D] = []
	var anchors: Array[Vector2] = []
	for p in spawned_points:
		if is_instance_valid(p):
			valid_points.append(p)
			anchors.append(p.global_position)

	spawned_points = valid_points

	if anchors.size() < 2:
		return

	var tangents: Array[Vector2] = []
	for i in range(anchors.size()):
		var curr: Vector2 = anchors[i]
		var prev: Vector2 = anchors[max(i - 1, 0)]
		var next: Vector2 = anchors[min(i + 1, anchors.size() - 1)]

		var tangent: Vector2 = (next - prev) * handle_strength

		if i > 0 and i < anchors.size() - 1 and is_peaking(prev.x, curr.x, next.x):
			tangent.x = 0.0

		tangents.append(tangent)

	var sampled_local: PackedVector2Array = PackedVector2Array()
	for i in range(anchors.size() - 1):
		var p0: Vector2 = anchors[i]
		var p1: Vector2 = anchors[i + 1]
		var c0: Vector2 = p0 + tangents[i]
		var c1: Vector2 = p1 - tangents[i + 1]

		for s in range(bezier_steps_per_segment + 1):
			if i > 0 and s == 0:
				continue
			var t: float = float(s) / float(bezier_steps_per_segment)
			var world_pt: Vector2 = cubic_bezier(p0, c0, c1, p1, t)
			sampled_local.append(to_local(world_pt))

	if sampled_local.size() < 2:
		return

	curve_line.points = sampled_local
	# curve_line.default_color = line_color
	# curve_line.width = line_width

func curve_formula(t: float) -> float:
	return screen_center.x + amplitude * (
		sin(frequency * t * TAU) + 0.5 * sin(frequency * t * TAU / 2.0)
	)

func spawn_point_at_x(spawn_x: float) -> void:
	var n: Node2D = point_scene.instantiate() as Node2D
	var target: Vector2 = Vector2(spawn_x, global_position.y)
	n.global_position = target

	get_parent().add_child(n)
	spawned_points.append(n)

func is_peaking(prev_x: float, curr_x: float, next_x: float) -> bool:
	var left_dx: float = curr_x - prev_x
	var right_dx: float = next_x - curr_x

	if is_zero_approx(left_dx) or is_zero_approx(right_dx):
		return false

	return left_dx * right_dx < 0.0

func cubic_bezier(p0: Vector2, c0: Vector2, c1: Vector2, p1: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return (u * u * u) * p0 + (3.0 * u * u * t) * c0 + (3.0 * u * t * t) * c1 + (t * t * t) * p1
