extends RayCast3D

@export var player_path : NodePath = "../Player"
var current_collider
@onready var color_no_collide = load("res://materials/material_blue.tres")
@onready var color_collide = load("res://materials/material_pink.tres")
@onready var player = get_node(player_path)

func _process(_delta):
	# track player position without inheriting the rotation
	global_position = get_node(player_path).global_position
	#get_node(player_path).on_floor = is_colliding()# and collider.is_in_group("level")
	#if is_colliding() and Input.is_action_just_pressed("jump"):
		##get_node(player_path).
		#print("collide")
	$DEBUG_Mesh.material_override = color_collide if is_colliding() else color_no_collide
