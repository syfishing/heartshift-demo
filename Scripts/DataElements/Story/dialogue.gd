extends StoryEvent
class_name StoryDialogueEvent

@export var character_id: String
@export var text: String
@export var typing_speed: float = 1.0
## When set to true, players cannot press a key to skip the dialogue.
@export var uninterruptible: bool = false
## When set to true, no player interaction is required at the end of the dialogue.
@export var auto_advance: bool = false
