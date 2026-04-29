extends Sprite2D

signal rating_broadcast(rating: String)

@export var DREAMY_WINDOW: float = 6.0
@export var GREAT_WINDOW: float = 14.0
@export var GOOD_WINDOW: float = 28.0
@export_enum("lane1", "lane2", "lane3") var input_lane: String = "lane1"

@export var show_debug_windows: bool = true

var overlapping_areas: Array[Area2D] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()
	#$AnimationPlayer.seek(0.3, true)
	#$AnimationPlayer.stop()
	$AnimationPlayer.play("HitMark")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(input_lane):
		$AnimationPlayer.stop()
		$AnimationPlayer.play("HitMark")
		check_hits()


func _draw() -> void:
	if not show_debug_windows:
		return

	var half_h: float = get_viewport_rect().size.y
	var debug_dreamy: float = DREAMY_WINDOW / 10.0
	var debug_great: float = GREAT_WINDOW / 10.0
	var debug_good: float = GOOD_WINDOW / 10.0

	# Draw from largest to smallest so tighter windows remain visible on top.
	draw_rect(
		Rect2(Vector2(-debug_good, -half_h), Vector2(debug_good * 2.0, half_h * 2.0)),
		Color(0.18, 0.65, 1.0, 0.15),
		true
	)
	draw_rect(
		Rect2(Vector2(-debug_great, -half_h), Vector2(debug_great * 2.0, half_h * 2.0)),
		Color(0.3, 1.0, 0.5, 0.2),
		true
	)
	draw_rect(
		Rect2(Vector2(-debug_dreamy, -half_h), Vector2(debug_dreamy * 2.0, half_h * 2.0)),
		Color(1.0, 0.95, 0.2, 0.26),
		true
	)

	# Exact hit center line.
	draw_line(Vector2(0.0, -half_h), Vector2(0.0, half_h), Color(1.0, 0.35, 0.35, 0.95), 2.0)


func check_hits() -> void:
	var line_x: float = global_position.x

	for area in overlapping_areas:
		if not is_instance_valid(area):
			continue

		# Is Hit code
		var point_node = area.get_parent()
		_process_point_hit(point_node)

		# Ranking code(I'll move it to a separate function eventually...)
		var relative_x: float = area.global_position.x - line_x
		var distance: float = abs(relative_x)
		var rating: String = "Pass"

		if distance <= DREAMY_WINDOW:
			rating = "Dreamy"
		elif distance <= GREAT_WINDOW:
			rating = "Great"
		elif distance <= GOOD_WINDOW:
			rating = "Good"

		rating_broadcast.emit(rating)


func _process_point_hit(point_node: Node) -> void:
	point_node.set("hit", true)


func _on_hit_area_entered(area: Area2D) -> void:
	if area == null:
		return

	if not overlapping_areas.has(area):
		overlapping_areas.append(area)

	# check_hits()


func _on_hit_area_exited(area: Area2D) -> void:
	var filtered_areas: Array[Area2D] = []

	for a in overlapping_areas:
		if not is_instance_valid(a):
			continue

		if a == area:
			continue

		filtered_areas.append(a)

	overlapping_areas = filtered_areas


func _on_fail_hit_area_entered(area: Area2D) -> void:
	if area == null:
		return

	var point_node = area.get_parent()
	var was_hit: bool = point_node.get("hit")
	if was_hit:
		return

	point_node.set("hit", true)
	rating_broadcast.emit("Fail")
