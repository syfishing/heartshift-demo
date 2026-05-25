extends Resource
class_name CharacterData

@export var id: String = ""
@export var name: String = "Unknown"
@export var color: Color = Color.GRAY
@export var poses: Dictionary[String, Texture2D] = {}
@export var default_pose: String
