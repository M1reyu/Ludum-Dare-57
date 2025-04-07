extends HSlider

var can_play_sound: bool = true

func _ready() -> void:
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)
	self.value = AudioPlayer.volume
	
	self.value_changed.connect(_on_volume_value_changed)
	
func _on_timer_timeout() -> void:
	self.can_play_sound = true

func _on_volume_value_changed(value: float) -> void:
	if value == self.min_value:
		AudioPlayer.volume = -40
		AudioPlayer.bg_music.set_volume_db(-50)
	else:
		AudioPlayer.volume = value
		AudioPlayer.bg_music.set_volume_db(value - 10.0)
	if self.can_play_sound == true:
		self.can_play_sound = false
		AudioPlayer.play_sfx("jump")
