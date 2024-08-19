extends AudioStreamPlayer

func update_audio_from_player_state():
	pitch_scale = (Globals.PLAYER_SCALE_LENGTH + 5.0)/6.0
	
	


func _on_update_audio_timer_timeout() -> void:
	update_audio_from_player_state()


func _on_toggle_sound_button_toggled(toggled_on: bool) -> void:
	playing = !playing


func _on_volume_slider_value_changed(value: float) -> void:
	volume_db = value
