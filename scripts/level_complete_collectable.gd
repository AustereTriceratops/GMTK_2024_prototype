extends Area3D


func _on_body_entered(_body: Node3D) -> void:
	print("_on_body_entered")
	$Explosion.explode()  
	$ExplosionSound.play()
	if $Timer.is_stopped():
		$Timer.start()

func _on_timer_timeout() -> void:
	Globals.complete_current_level()
