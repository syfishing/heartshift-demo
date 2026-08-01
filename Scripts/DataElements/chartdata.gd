extends Resource
class_name ChartData

@export var bpm: int
@export var notes: Array[NoteData] = []
@export var audio: AudioStream
@export var cover: Texture2D
@export var song_colour: Color

#Label Tags
@export var name: String
@export var artist_name: String
@export var charter_name: String
@export var stage: int
@export var difficulty: int
