extends Button

@onready var highlight = $Highlight
@onready var text_element = $StorySelectText

func _ready():
	highlight.visible = false
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	connect("focus_entered", _on_focus_entered)
	connect("focus_exited", _on_focus_exited)

func _on_mouse_entered():
	# Tell parent that THIS button is hovered
	get_parent().call("on_button_hovered", self)
	highlight.visible = true
	grab_focus()

func _on_mouse_exited():
	if not has_focus():
		highlight.visible = false

func _on_focus_entered():
	# Tell parent that THIS button is focused
	get_parent().call("on_button_focused", self)
	highlight.visible = true

func _on_focus_exited():
	if not is_hovered():
		highlight.visible = false
