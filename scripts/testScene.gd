extends Node3D

func increment_score():
	$PlayerScene/Player.config['jumpImpulse'] += 1;

	var local_scale = $PlayerScene/Player/Mesh.scale + Vector3(0, 0.1, 0);
	$PlayerScene/Player.set_scale_length(local_scale.y)
	print($PlayerScene/Player/Mesh.scale)
