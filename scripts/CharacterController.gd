extends RigidBody3D;

@onready var mainNode = get_node('/root/main');

var config = {
	'jumpImpulse': 10,
	'doubleJumpImpulse': 10,
	'angularVelocity': 3.0,
}

var legalInput = {
	'jump': true,
	'doubleJump': false,
}

var pendingInput = {
	'jump': false,
	'doubleJump': false,
}

func _integrate_forces(state):
	if pendingInput['jump']:
		pendingInput['jump'] = false;
		
		var collisionPos = state.get_contact_local_position(0);
		var diff = position - collisionPos;
		diff.z = 0;
		var launchDir = -diff.normalized();
		apply_central_impulse(config['jumpImpulse']*launchDir);
		
	if pendingInput['doubleJump']:
		pendingInput['doubleJump'] = false;
		
		apply_central_impulse(config['doubleJumpImpulse']*Vector3(0, -1, 0));

func _process(delta):
	var nContacts = get_contact_count();
	
	if Input.is_action_pressed('a'):
		set_angular_velocity(config['angularVelocity'] * Vector3(0, 0, 1));
	if Input.is_action_pressed('d'):
		set_angular_velocity(-config['angularVelocity'] * Vector3(0, 0, 1));
	
	if Input.is_action_just_pressed('jump'):
		print(nContacts)
		if nContacts == 1 || nContacts == 2:
			pendingInput['jump'] = true;
			legalInput['doubleJump'] = true;
		elif nContacts == 0 && legalInput['doubleJump']:
			pendingInput['doubleJump'] = true;
			legalInput['doubleJump'] = false;
