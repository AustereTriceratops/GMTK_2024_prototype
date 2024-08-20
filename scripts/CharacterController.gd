extends RigidBody3D

signal scale_changed(new_scale: float)

var move_input = Vector2.ZERO
var is_on_floor = true
var velocity = Vector3()

@onready var feet : Node = $"../GroundDetectionRaycast3D"
@onready var feet1 : Node = $Collider/RayCast3D
@onready var feet2 : Node = $Collider/RayCast3D2
@onready var collider : CollisionShape3D = $Collider
@onready var mesh : MeshInstance3D = $Mesh
@onready var meterstick_mat : ShaderMaterial = \
	 preload("res://shaders/meterstick_material.tres")
	
var double_jump_allowed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	linear_damp = 1.0
	Globals.player_update.connect(on_player_update)
	Globals.set_player(self)
	
func on_player_update():
	print("on_player_update")
	meterstick_mat.set_shader_parameter("y_scale", 1.0)
	set_scale_length(Globals.PLAYER_SCALE_LENGTH)
	
	
func set_scale_length(new_size: float):
	collider.set_scale(Vector3(1, new_size, 1))
	mesh.set_scale(Vector3(1, new_size, 1))
	meterstick_mat.set_shader_parameter("y_scale", new_size)
	scale_changed.emit(new_size)
	
func get_scale_length():
	return collider.scale.y

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed('a'):
		set_angular_velocity(Globals.PLAYER_ANGULARVELOCITY * Vector3(0, 0, 1));
	if Input.is_action_pressed('d'):
		set_angular_velocity(-Globals.PLAYER_ANGULARVELOCITY * Vector3(0, 0, 1));

	if gravity_scale >= 0: gravity_scale = 0
	is_on_floor = false
	#if feet.is_colliding():
	# linear movement allowed if on ground
	move_input = Vector2.ZERO
	var dir = Vector3()
	move_input = Input.get_vector("a","d", "s", "w")
	dir += move_input.x*feet.global_transform.basis.x;
	dir -= move_input.y*feet.global_transform.basis.z;
	velocity = lerp(velocity, dir*Globals.PLAYER_MAX_SPEED, \
		Globals.PLAYER_ACCELERATION * Globals.PLAYER_ACCEL_MULTIPLIER * delta)
	apply_central_force(velocity)
	
	if get_contact_count() > 0 and feet.is_colliding():
		# linear movement allowed if on ground
		# note that we're on floor
		is_on_floor = true
		gravity_scale = 1.0
		Globals.PLAYER_ACCEL_MULTIPLIER = 1.0
		double_jump_allowed = true
	else:
		is_on_floor = false
		gravity_scale = 1.0;
	if Input.is_action_just_pressed("jump"):
		if is_on_floor: # can jump
			Globals.PLAYER_ACCEL_MULTIPLIER  = 0.1
			is_on_floor = false
			apply_central_impulse(Vector3.UP * Globals.PLAYER_JUMP_SPEED)
		elif double_jump_allowed: # falling but can double-jump
			double_jump_allowed = false
			Globals.PLAYER_ACCEL_MULTIPLIER  = 0.1
			is_on_floor = false
			apply_central_impulse(Vector3.UP * Globals.PLAYER_JUMP_SPEED)

func _integrate_forces(state):
	#limit max speed
	if state.linear_velocity.length()>Globals.PLAYER_MAX_SPEED :
		state.linear_velocity=state.linear_velocity.normalized()*Globals.PLAYER_MAX_SPEED 
	#artificial stopping movement i.e not using physics
	if move_input.length() < 0.2:
		state.linear_velocity.x = clamp(state.linear_velocity.x,0,Globals.PLAYER_STOP_SPEED )
		state.linear_velocity.z = clamp(state.linear_velocity.z,0,Globals.PLAYER_STOP_SPEED )
	#push against floor to avoid sliding on "unreasonable" slopes
	if state.get_contact_count() > 0 and move_input.length()< 0.2:
		if is_on_floor and state.get_contact_local_normal(0).y < 0.9:
			apply_central_force(-state.get_contact_local_normal(0)*10)
