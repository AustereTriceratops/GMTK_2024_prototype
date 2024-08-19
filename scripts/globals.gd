extends Node

signal player_update()

@export var PLAYER_SCALE_LENGTH = 1.0
@export var PLAYER_JUMP_SPEED = 5
@export var PLAYER_DOUBLEJUMPIMPULSE = 30
@export var PLAYER_ANGULARVELOCITY = 8.0
@export var PLAYER_GRAVITY = 0.2
@export var PLAYER_ACCELERATION = 5.0
@export var PLAYER_ACCEL_MULTIPLIER = 1.0
@export var PLAYER_SPEED = 10
@export var PLAYER_MAX_SPEED = 20
@export var PLAYER_STOP_SPEED = 0.1

var player

func set_player(current_player):
	player = current_player

func increment_score():
	PLAYER_SCALE_LENGTH += 0.1
	PLAYER_JUMP_SPEED += 0.4
	player_update.emit()
	if is_instance_valid(player):
		player.set_scale_length(PLAYER_SCALE_LENGTH)
