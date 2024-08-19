extends Node3D

func increment_score():
	Globals.PLAYER_SCALE_LENGTH += 0.1
	Globals.PLAYER_JUMP_SPEED += 1
	$PlayerScene/Player.set_scale_length(Globals.PLAYER_SCALE_LENGTH)
	print($PlayerScene/Player/Mesh.scale)
