extends Node3D

class_name Explosion

func explode():
	$Debris.emitting = true
	$Smoke.emitting = true
	$Fire.emitting = true


func _on_visibility_changed() -> void:
	if visible:
		explode()
