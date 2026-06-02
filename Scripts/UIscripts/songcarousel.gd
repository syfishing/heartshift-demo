@tool
extends Control
class_name CarouselContainer

@export_range(0.0, 1.0) var opacity_strength: float = 0.35
@export_range(0.0, 1.0) var scale_strength: float = 0.25
@export_range(0.0, 1.0) var scale_min: float = 0.1
@export var smoothing_speed: float = 6.5
@export var spacing: float = 25.0

@export var selected_index: int = 0


@export var position_offset_node: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CarouselOffset.get_child(selected_index).toggle()
	update_card()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !position_offset_node or position_offset_node.get_child_count() == 0: return
	
	selected_index = clamp(selected_index, 0, position_offset_node.get_child_count() - 1)
	
	for child in position_offset_node.get_children():
		var i: int = child.get_index()
		var distance: int = i - selected_index
		
		var position_y: float = 0.0
		if i > 0:
			var prev := position_offset_node.get_child(i-1)
			position_y = prev.position.y + prev.size.y + spacing
		
		child.position = Vector2(-child.size.x / 2, position_y)
		
		#scaling based on dist
		var target_scale: float = 1.0 - (scale_strength * abs(distance))
		target_scale = clamp(target_scale, scale_min, 1.0)
		child.scale = lerp(child.scale, Vector2.ONE * target_scale, smoothing_speed * delta)
		
		#opacity based on dist
		var target_opacity: float = 1.0 - (opacity_strength * abs(distance**2))
		
		target_opacity = clamp(target_opacity, 0.0, 1.0)
		child.modulate.a = lerp(child.modulate.a, target_opacity, smoothing_speed * delta)
		
	var selected_child = position_offset_node.get_child(selected_index)
	
	#var target_x = -(selected_child.position.x + selected_child.size.x / 2.0 - size.x / 2)
	var target_y = -(selected_child.position.y + selected_child.size.y / 2.0 - size.y / 2)
	
	#position_offset_node.position.x = lerp(position_offset_node.position.x, target_x, smoothing_speed * delta)
	position_offset_node.position.y = lerp(position_offset_node.position.y, target_y, smoothing_speed * delta)



func _on_up_button_pressed() -> void:
	if selected_index == 0: return
	$CarouselOffset.get_child(selected_index).toggle()
	selected_index -= 1
	$CarouselOffset.get_child(selected_index).toggle()
	update_card()
	pass # Replace with function body.


func _on_down_button_pressed() -> void:
	if selected_index == position_offset_node.get_child_count() - 1: return
	$CarouselOffset.get_child(selected_index).toggle()
	selected_index += 1
	$CarouselOffset.get_child(selected_index).toggle()
	update_card()
	pass # Replace with function body.


func update_card():
	var selected_element = $CarouselOffset.get_child(selected_index)
	
	if !selected_element.chart: return
	%SongCover.texture = selected_element.chart.cover
	%LevelDifficultyLabel.text = str(selected_element.chart.difficulty)
	%LengthLabel.text = get_audio_length_formatted(selected_element.chart.audio)
	

func get_audio_length_formatted(stream: AudioStream) -> String:
	var length_seconds: float = stream.get_length()
	
	if length_seconds <= 0:
		return "need to put this in WAV format!!"

	var minutes: int = int(length_seconds) / 60
	var seconds: int = int(length_seconds) % 60
	
	# Format with zero‑padding for seconds
	return "%d:%02d" % [minutes, seconds]
