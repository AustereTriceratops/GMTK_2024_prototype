extends Camera3D

@onready var rigidBody = get_node('../Player');

func _process(delta):
	set_position(rigidBody.position + Vector3(0, 0, 3));
	
