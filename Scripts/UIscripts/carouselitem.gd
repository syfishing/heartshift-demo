extends Button

@export var item_colour: Color
@export var chart: ChartData

@onready var grid_mat: Material = $GridBG.material.duplicate()
@onready var wave_mat: Material = $Wave.material.duplicate()
var initial_item_colour: Color

var active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if chart:
		item_colour = chart.song_colour
		$SongName.text = chart.name
	initial_item_colour = item_colour
	item_colour = Color("1f1f1f")
	
	
	deactivate()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$WaveBG.self_modulate = item_colour
	$Wave.material = wave_mat
	
	grid_mat.set_shader_parameter("line_color", Color(item_colour.r,item_colour.g,item_colour.b, 0.51))
	$GridBG.material = grid_mat

func toggle():
	if active == false:
		active = true
		activate()

	else:
		active = false
		deactivate()

func deactivate():
	var tween = create_tween()
	tween.tween_property(self, "item_colour", Color("#1f1f1f"), 0.25)
	
	var wave_tween = create_tween()
	wave_tween.tween_property(wave_mat, "shader_parameter/rest_size", 5, 0.25)
	
func activate():
	var tween = create_tween()
	tween.tween_property(self, "item_colour", initial_item_colour, 0.25)
	
	var wave_tween = create_tween()
	wave_tween.tween_property(wave_mat, "shader_parameter/rest_size", 2, 0.25)
