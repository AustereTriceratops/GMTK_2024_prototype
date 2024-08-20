extends AudioStreamPlayer

@onready var score_increment_sfx = load("res://audio/sfx/empty_da.wav")
@onready var sfx_player = $SFXPlayer
@onready var vol_slider = $"../HBoxContainer/VolumeSlider"


func _ready() -> void:
	Globals.score_increment.connect(on_score_increment)
	Globals.current_level_complete.connect(on_level_completed)
	vol_slider.value = volume_db
	vol_slider.value_changed.connect(_on_volume_slider_value_changed)
	
func on_level_completed(level):
	pass
	
func on_score_increment():
	sfx_player.stream = score_increment_sfx
	sfx_player.play()

func update_audio_from_player_state():
	pitch_scale = (Globals.PLAYER_SCALE_LENGTH + 5.0)/6.0
	
func _on_update_audio_timer_timeout() -> void:
	update_audio_from_player_state()

func _on_toggle_sound_button_toggled(toggled_on: bool) -> void:
	playing = !playing 

func _on_volume_slider_value_changed(value: float) -> void:
	volume_db = value
	sfx_player.volume_db = value
