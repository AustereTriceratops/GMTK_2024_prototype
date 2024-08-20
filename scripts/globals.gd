extends Node

signal player_update()
signal score_increment()
signal current_level_complete(current_level:int)

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

@export var level_complete = [false, true, false]
@export var current_level = 0

var player

func set_player(current_player):
	player = current_player

func complete_current_level():
	level_complete[current_level] = true
	current_level_complete.emit(current_level)

func increment_score():
	PLAYER_SCALE_LENGTH += 0.1
	PLAYER_JUMP_SPEED += 0.4
	player_update.emit()
	score_increment.emit()
	if is_instance_valid(player):
		player.set_scale_length(PLAYER_SCALE_LENGTH)
