@tool
extends EditorScenePostImport

var collisionshapes = []
var transforms = []

func _post_import(scene):

	iterate_scene(scene, scene)
	
	#for staticbody in staticbodies:
	#	staticbody.set_owner(null)
	#	staticbody.reparent(scene)
	#	staticbody.set_owner(scene)
		
	for basecollisionshape_transform in collisionshapes:
		var staticbody = StaticBody3D.new()
		scene.add_child(staticbody)
		staticbody.set_owner(scene)
		
		var collisionshape = CollisionShape3D.new()
		staticbody.add_child(collisionshape)
		collisionshape.set_owner(scene)
		
		collisionshape.shape = basecollisionshape_transform[0].shape
		staticbody.transform = basecollisionshape_transform[1]
		staticbody.collision_layer = 2
		
		
		

	return scene


func iterate_scene(scene, node):
	for child in node.get_children():
		iterate_scene(scene, child)
	
	if node is not MeshInstance3D: return
	var mesh_inst : MeshInstance3D = node
	
	#var body = StaticBody3D.new()
	#body.name = "StaticBody3D_" + node.name
	
	if scene.name == "forest_collision":
		mesh_inst.create_trimesh_collision()
	else:
		mesh_inst.create_convex_collision()
	
	
	for staticbody in node.get_children():
		if staticbody is StaticBody3D:
			for collisionshape in staticbody.get_children():
				if collisionshape is CollisionShape3D:
					collisionshapes.append([collisionshape, node.transform])
				
			
