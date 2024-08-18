extends Node3D

func increment_score():
	$PlayerScene/Player/Collider.shape.height += 0.1;
	$PlayerScene/Player.config['jumpImpulse'] += 1;

	var local_scale = $PlayerScene/Player/Mesh.scale;
	$PlayerScene/Player/Mesh.set_scale(local_scale + Vector3(0, 0.1, 0));
	print($PlayerScene/Player/Mesh.scale)
