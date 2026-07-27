extends Sprite2D

signal rating_broadcast(rating: String, lane: String)

@export var DREAMY_WINDOW_MS: float = 35.0
@export var GREAT_WINDOW_MS: float = 45.0
@export var GOOD_WINDOW_MS: float = 55.0
@export var PASS_WINDOW_MS: float = 70.0

@export_enum("lane1", "lane2", "lane3") var input_lane: String = "lane1"

@export var show_debug_windows: bool = true

@export var conductor_path: NodePath = ^"../Conductor"

const LANES: Array[String] = ["lane1", "lane2", "lane3"]

var conductor: Node = null
var lane_index: int = 0
var active_hold: Node2D = null
var hold_head_rating: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	conductor = get_node_or_null(conductor_path)
	lane_index = maxi(LANES.find(input_lane), 0)
	queue_redraw()
	#$AnimationPlayer.seek(0.3, true)
	#$AnimationPlayer.stop()
	$AnimationPlayer.play("HitMark")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if conductor == null or not conductor.is_playing():
		return

	var song_time: float = conductor.song_time

	if Input.is_action_just_pressed(input_lane):
		$AnimationPlayer.stop()
		$AnimationPlayer.play("HitMark")
		judge_press(song_time)

	judge_misses(song_time)
	update_hold(song_time)


func judge_press(song_time: float) -> void:
	var note: Node2D = conductor.get_hittable_note(lane_index, song_time, PASS_WINDOW_MS / 1000.0)
	if note == null:
		return

	var error_ms: float = absf(song_time - note.hit_time) * 1000.0
	var rating: String = get_rating(error_ms)

	note.start_hit()
	AudioHub.play_note_sfx()

	if note.is_hold_note():
		active_hold = note
		hold_head_rating = rating
	else:
		rating_broadcast.emit(rating, input_lane)


func judge_misses(song_time: float) -> void:
	var missed: Node2D = conductor.take_missed_note(lane_index, song_time, PASS_WINDOW_MS / 1000.0)

	while missed != null:
		missed.fail_note()
		rating_broadcast.emit("Fail", input_lane)
		$FailParticle.emitting = true
		missed = conductor.take_missed_note(lane_index, song_time, PASS_WINDOW_MS / 1000.0)


func update_hold(song_time: float) -> void:
	if active_hold == null:
		return

	if not is_instance_valid(active_hold):
		active_hold = null
		hold_head_rating = ""
		return

	if Input.is_action_just_released(input_lane):
		if song_time >= active_hold.end_time:
			active_hold.complete_hold()
			rating_broadcast.emit(hold_head_rating, input_lane)

		else:
			active_hold.fail_note()
			rating_broadcast.emit("Fail", input_lane)
			$FailParticle.emitting = true

		active_hold = null
		hold_head_rating = ""

	elif song_time >= active_hold.end_time:
		active_hold.complete_hold()
		rating_broadcast.emit(hold_head_rating, input_lane)
		active_hold = null
		hold_head_rating = ""


func get_rating(error_ms: float) -> String:
	if error_ms <= DREAMY_WINDOW_MS:
		return "Dreamy"
	elif error_ms <= GREAT_WINDOW_MS:
		return "Great"
	elif error_ms <= GOOD_WINDOW_MS:
		return "Good"
	else:
		return "Pass"


func _draw() -> void:
	if not show_debug_windows:
		return

	var note_speed: float = conductor.get_note_speed() if conductor != null else 0.0
	var px_per_ms: float = note_speed / 1000.0 / maxf(absf(scale.x), 0.0001)

	var half_h: float = get_viewport_rect().size.y
	var debug_dreamy: float = DREAMY_WINDOW_MS * px_per_ms
	var debug_great: float = GREAT_WINDOW_MS * px_per_ms
	var debug_good: float = GOOD_WINDOW_MS * px_per_ms
	var debug_pass: float = PASS_WINDOW_MS * px_per_ms

	# Draw from largest to smallest so tighter windows remain visible on top.
	draw_rect(
		Rect2(Vector2(-debug_pass, -half_h), Vector2(debug_pass * 2.0, half_h * 2.0)),
		Color(0.6, 0.6, 0.6, 0.1),
		true
	)
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
