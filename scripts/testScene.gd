extends Node3D

func increment_score():
	$PlayerScene/Player/Collider.shape.height += 0.1;
	$PlayerScene/Player.config['jumpImpulse'] += 1;

	var scale = $PlayerScene/Player/Mesh.scale;
	$PlayerScene/Player/Mesh.set_scale(scale + Vector3(0.1, 0, 0));
