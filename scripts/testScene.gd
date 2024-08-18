extends Node2D

var colliderHeight = 230

func increment_score():
	$playerScene/Player/Collider.shape.height += 30;
	$playerScene/Player.config['jumpImpulse'] += 50;
	$playerScene/Player/Camera.zoom *= 0.95;
	
	var scale = $playerScene/Player/Sprite.scale;
	$playerScene/Player/Sprite.set_scale(scale + Vector2(0.2, 0));
