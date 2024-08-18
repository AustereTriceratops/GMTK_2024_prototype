extends RigidBody3D

var config = {
	'jumpImpulse':30,
	'doubleJumpImpulse': 15,
	'angularVelocity': 4.0,
	'gravity': 0.2,
}

var jump_vel = 5
var acceleration = 5.0
var accel_multiplier = 1.0
var speed = 10
var max_speed = 20
var move_input = Vector2.ZERO
var is_on_floor = true
var sense = 9.0
var stop_speed = 0.1

var velocity = Vector3()

@onready var feet : Node = $"../GroundDetectionRaycast3D"

# Called when the node enters the scene tree for the first time.
func _ready():
	linear_damp = 1.0

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed('a'):
		set_angular_velocity(config['angularVelocity'] * Vector3(0, 0, 1));
	if Input.is_action_pressed('d'):
		set_angular_velocity(-config['angularVelocity'] * Vector3(0, 0, 1));

	if gravity_scale >= 0: gravity_scale = 0
	is_on_floor = false
	
	if feet.is_colliding():
		# linear movement allowed if on ground
		move_input = Vector2.ZERO
		var dir = Vector3()
		move_input = Input.get_vector("a","d", "s", "w")
		dir += move_input.x*feet.global_transform.basis.x;
		dir -= move_input.y*feet.global_transform.basis.z;
		velocity = lerp(velocity, dir*max_speed, acceleration * accel_multiplier * delta)
		apply_central_force(velocity)
		# note that we're on floor
		is_on_floor = true
		gravity_scale = 1.0
		accel_multiplier = 1.0
	if Input.is_action_just_pressed("jump") and is_on_floor:
		accel_multiplier = 0.1
		is_on_floor = false
		apply_central_impulse(Vector3.UP * jump_vel)
	elif !feet.is_colliding():
		is_on_floor = false
		gravity_scale = 1.0;

func _integrate_forces(state):
	#limit max speed
	if state.linear_velocity.length()>max_speed:
		state.linear_velocity=state.linear_velocity.normalized()*max_speed
	#artificial stopping movement i.e not using physics
	if move_input.length() < 0.2:
		state.linear_velocity.x = clamp(state.linear_velocity.x,0,stop_speed)
		state.linear_velocity.z = clamp(state.linear_velocity.z,0,stop_speed)
	#push against floor to avoid sliding on "unreasonable" slopes
	if state.get_contact_count() > 0 and move_input.length()< 0.2:
		if is_on_floor and state.get_contact_local_normal(0).y < 0.9:
			apply_central_force(-state.get_contact_local_normal(0)*10)
