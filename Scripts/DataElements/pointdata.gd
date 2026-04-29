extends Resource
class_name NoteData

@export var hit_time: float  # In seconds
@export var track: int = 0       # 0, 1, or 2
@export var type: String = "tap"     # "tap" or "hold" I guess, maybe I'll use an enum later?
@export var travel_time_multiplier : float = 1 # Multiplies time it takes the note to reach(muehehehe)
