extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.change_music(AudioPlayer.SCENE_SET.MENU)
