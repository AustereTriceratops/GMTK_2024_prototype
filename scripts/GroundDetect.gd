extends RayCast3D

@export var player_path : NodePath = "../Player"
@export var player_collider_path : NodePath = "../Player"
var current_collider
@onready var color_no_collide = load("res://materials/material_blue.tres")
@onready var color_collide = load("res://materials/material_pink.tres")
@onready var player = get_node(player_path)

func _process(_delta):
	# track player position without inheriting the rotation
	global_position = get_node(player_path).global_position
	$DEBUG_Mesh.material_override = color_collide if is_colliding() else color_no_collide


func _on_player_scale_changed(_new_scale: float) -> void:
	pass #target_position = Vector3.DOWN * get_node(player_path).get_scale_length()
