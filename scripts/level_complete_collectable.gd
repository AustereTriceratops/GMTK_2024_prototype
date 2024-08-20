extends Area3D

func _on_body_entered(body: Node3D) -> void:
	Globals.level_complete[Globals.current_level] = true
	$Explosion.explode()
	$LevelCompleteSound.play()
