extends Camera3D

@onready var rigidBody = get_node('../Player');

var camera_distance = 3

func _ready() -> void:
	Globals.player_update.connect(on_player_update)
	
func on_player_update():
	camera_distance = 3 + Globals.PLAYER_SCALE_LENGTH

func _process(_delta):
	set_position(rigidBody.position + Vector3(0, 0, camera_distance));
	
