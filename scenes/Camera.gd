extends Camera3D

@onready var rigidBody = get_node('../Player');

func _process(_delta):
	set_position(rigidBody.position + Vector3(0, 0, 3));
	
