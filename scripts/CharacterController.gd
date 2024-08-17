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
	if pendingInput['jump']:
		pendingInput['jump'] = false;
		
		var collisionPos = state.get_contact_local_position(0);
		var launchDir = (position - collisionPos).normalized();
		apply_central_impulse(config['jumpImpulse']*launchDir)
		
	if pendingInput['doubleJump']:
		pendingInput['doubleJump'] = false;
		
		apply_central_impulse(config['doubleJumpImpulse']*Vector2(0, -1));

func _process(delta):
	var nContacts = get_contact_count();
	
	if Input.is_action_pressed('q'):
		print(rotation);
	if Input.is_action_pressed('e'):
		pass
	if Input.is_action_pressed('a'):
		angular_velocity = -config['angularVelocity'];
	if Input.is_action_pressed('d'):
		angular_velocity = config['angularVelocity'];
	if Input.is_action_just_pressed('jump'):
		if nContacts == 1:
			pendingInput['jump'] = true;
			legalInput['doubleJump'] = true;
		elif nContacts == 0 && legalInput['doubleJump']:
			print('doubleJump')
			pendingInput['doubleJump'] = true;
			legalInput['doubleJump'] = false;
