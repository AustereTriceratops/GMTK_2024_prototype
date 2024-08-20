extends Node3D

func explode():
	$Debris.emitting = true
	$Smoke.emitting = true
	$Fire.emitting = true
