extends Button

@onready var highlight = $Highlight
@onready var text_element = $StorySelectText
var cursor: Control

@export var rest_color: Color = Color("483901")
@export var active_color: Color = Color()

func _ready():
	if %Cursor:
		print("cursor")
		cursor = %Cursor
	highlight.visible = false
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	connect("focus_entered", _on_focus_entered)
	connect("focus_exited", _on_focus_exited)
	connect("button_down", _on_button_down)
	animate_text_color(rest_color)

func _on_mouse_entered():
	highlight.visible = true
	grab_focus()

func _on_button_down() -> void:
	pass
	#z_index = 1
	#pass # Replace with function body.


func _on_mouse_exited():
	pass

func _on_focus_entered():
	highlight.visible = true
	animate_highlight(0.0, 1.0)
	animate_text_color(Color.BLACK)
	#animate_cursor()
	if cursor:
		cursor.position = Vector2(cursor.position.x, position.y+14.0825)

func _on_focus_exited():
	animate_highlight(1.0, 0.0)
	animate_text_color(rest_color)

func animate_highlight(from_anchor: float, to_anchor: float):
	var tween = create_tween()
	highlight.anchor_right = from_anchor
	tween.tween_property(highlight, "anchor_right", to_anchor, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func animate_text_color(target_color: Color):
	var tween = create_tween()
	tween.tween_property(text_element, "self_modulate", target_color, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

#func animate_cursor():
	#var tween = create_tween()
	#tween.tween_property(cursor, "position:y", position.y+14.0825, 0.3)\
		#.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
