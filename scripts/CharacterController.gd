extends RigidBody3D;

@onready var mainNode = get_node('/root/main');

var config = {
	'jumpImpulse': 1000,
	'doubleJumpImpulse': 500,
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
	if Input.is_action_pressed('w'):
		var v = linear_velocity.length();
		var fac = 0.03*clamp(700 - v, 0, 700);
		apply_central_force(fac*Vector3(-0.707, -0.707, 0));
	if Input.is_action_pressed('s'):
		apply_central_force(10*Vector3(0, 1, 0));
	if pendingInput['jump']:
		pendingInput['jump'] = false;
		
		var collisionPos = state.get_contact_local_position(0);
		var diff = position - collisionPos;
		diff.z = 0;
		var launchDir = diff.normalized();
		apply_central_impulse(config['jumpImpulse']*launchDir);
		
	if pendingInput['doubleJump']:
		pendingInput['doubleJump'] = false;
		
		apply_central_impulse(config['doubleJumpImpulse']*Vector3(0, -1, 0));

func _process(delta):
	var nContacts = get_contact_count();
	
	if Input.is_action_pressed('a'):
		print('a')
		set_angular_velocity(-config['angularVelocity'] * Vector3(0, 0, 1));
	if Input.is_action_pressed('d'):
		set_angular_velocity(config['angularVelocity'] * Vector3(0, 0, 1));
	if Input.is_action_just_pressed('jump'):
		if nContacts == 1:
			pendingInput['jump'] = true;
			legalInput['doubleJump'] = true;
		elif nContacts == 0 && legalInput['doubleJump']:
			pendingInput['doubleJump'] = true;
			legalInput['doubleJump'] = false;
