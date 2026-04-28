extends Node2D

@export var curve_line: Line2D
@export var point_nodes: Array[Node2D] = []

@export var handle_strength: float = 0.25
@export var max_handle_ratio_per_segment: float = 0.4
@export var bezier_steps_per_segment: int = 16

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if curve_line == null:
		return

	if point_nodes.size() < 2:
		return

	var valid_points: Array[Node2D] = []
	var anchors: Array[Vector2] = []
	for p in point_nodes:
		if is_instance_valid(p):
			valid_points.append(p)
			anchors.append(p.global_position)

	point_nodes = valid_points

	if anchors.size() < 2:
		return

	var tangents: Array[Vector2] = []
	for i in range(anchors.size()):
		var curr: Vector2 = anchors[i]
		var prev: Vector2 = anchors[max(i - 1, 0)]
		var next: Vector2 = anchors[min(i + 1, anchors.size() - 1)]

		var tangent: Vector2 = (next - prev) * handle_strength
		var left_len: float = curr.distance_to(prev)
		var right_len: float = curr.distance_to(next)
		var len_ratio: float = min(left_len, right_len) / max(max(left_len, right_len), 0.001)
		tangent *= len_ratio

		if i > 0 and i < anchors.size() - 1 and is_peaking(prev.y, curr.y, next.y):
			tangent.y = 0.0

		tangents.append(tangent)

	var sampled_local: PackedVector2Array = PackedVector2Array()
	for i in range(anchors.size() - 1):
		var p0: Vector2 = anchors[i]
		var p1: Vector2 = anchors[i + 1]
		var c0: Vector2 = p0 + tangents[i]
		var c1: Vector2 = p1 - tangents[i + 1]

		c0 = clamp_handle_to_segment(p0, c0, p1)
		c1 = clamp_handle_to_segment(p1, c1, p0)

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

func is_peaking(prev_value: float, curr_value: float, next_value: float) -> bool:
	var left_d: float = curr_value - prev_value
	var right_d: float = next_value - curr_value

	if is_zero_approx(left_d) or is_zero_approx(right_d):
		return false

	return left_d * right_d < 0.0

func cubic_bezier(p0: Vector2, c0: Vector2, c1: Vector2, p1: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return (u * u * u) * p0 + (3.0 * u * u * t) * c0 + (3.0 * u * t * t) * c1 + (t * t * t) * p1

func clamp_handle_to_segment(anchor: Vector2, control: Vector2, other_anchor: Vector2) -> Vector2:
	var max_len: float = anchor.distance_to(other_anchor) * max_handle_ratio_per_segment
	if is_zero_approx(max_len):
		return anchor

	var handle: Vector2 = control - anchor
	var handle_len: float = handle.length()
	if handle_len > max_len and handle_len > 0.0:
		return anchor + (handle / handle_len) * max_len

	return control
