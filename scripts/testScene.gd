extends Node2D

var colliderHeight = 230

func increment_score(val):
	$playerScene/Player/Collider.shape.height += 30;
	
	var scale = $playerScene/Player/Sprite.scale;
	$playerScene/Player/Sprite.set_scale(scale + Vector2(0.2, 0));
