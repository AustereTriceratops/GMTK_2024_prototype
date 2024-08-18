extends RigidBody2D;

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
		apply_central_impulse(fac*Vector2(-0.707, -0.707));
	if Input.is_action_pressed('s'):
		apply_central_impulse(10*Vector2(0, 1));
	if pendingInput['jump']:
		pendingInput['jump'] = false;
		
		var collisionPos = state.get_contact_local_position(0);
		var launchDir = (position - collisionPos).normalized();
		apply_central_impulse(config['jumpImpulse']*launchDir);
		
	if pendingInput['doubleJump']:
		pendingInput['doubleJump'] = false;
		
		apply_central_impulse(config['doubleJumpImpulse']*Vector2(0, -1));

func _process(delta):
	var nContacts = get_contact_count();
	
	if Input.is_action_pressed('a'):
		angular_velocity = -config['angularVelocity'];
	if Input.is_action_pressed('d'):
		angular_velocity = config['angularVelocity'];
	if Input.is_action_just_pressed('jump'):
		if nContacts == 1:
			pendingInput['jump'] = true;
			legalInput['doubleJump'] = true;
		elif nContacts == 0 && legalInput['doubleJump']:
			pendingInput['doubleJump'] = true;
			legalInput['doubleJump'] = false;
