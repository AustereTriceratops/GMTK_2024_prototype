@tool
extends EditorScenePostImport

var node_extras_dict = {}
var remove_nodes = []

# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	# Change all node names to "modified_[oldnodename]"

	var file = FileAccess.open(get_source_file(), FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		parseGLTF(json.data)
		iterateScene(scene)
		deleteExtras()
		run_init(scene)
	
	#scene.set_script(load("res://addons/blender_godot_pipeline/SceneInit.gd"))
	#scene.set_meta("run", true)
	
	return scene # Remember to return the imported scene


func deleteExtras():
	for node in remove_nodes:
		print("Removed " + node.name)
		node.free()

func parseGLTF(json):
	# go through each node and find ones which references meshes
	if "nodes" in json:
		for node in json["nodes"]:
			if "mesh" in node:
				var mesh_index = node["mesh"]
				var mesh = json["meshes"][mesh_index]
				if "extras" in mesh:
					addExtrasToDict(node["name"], mesh["extras"])
				
			if "extras" in node:
				addExtrasToDict(node["name"], node["extras"])

func addExtrasToDict(nodeName, extras):
	var gNodeName = nodeName.replace(".", "_")
	if gNodeName not in node_extras_dict:
		node_extras_dict[gNodeName] = {}
	for extra in extras:
		node_extras_dict[gNodeName][extra] = str(extras[extra])

func iterateScene(node):
	if node != null:
		if (node.name in node_extras_dict) and (node is MeshInstance3D):
			var extras = node_extras_dict[node.name]
			print("Set extras for: " + node.name)
			for key in extras:
				print(key + "=" + extras[key])
				node.set_meta(key, extras[key])
			
		# anything directly baked from simple bake should not be imported
		# either materials are used from a bake
		# or an instance should be used
		#if node.name.ends_with("_Baked"):
		#	remove_nodes.append(node)
		
		if "_Remove" in node.name:
			remove_nodes.append(node)
		
		if node.name.ends_with("_Inst"):
			remove_nodes.append(node)
		
	for child in node.get_children():
		iterateScene(child)


var reparent_nodes = []
var delete_nodes = []

func run_init(scene):
	#if Engine.is_editor_hint():
	#	if get_meta("run"):
	#		print("Running scene init")
	
	iterate_scene(scene,scene)
	reparent_pass(scene)
	delete_pass()
	
	# ensure that SceneInit only runs once
	#set_meta("run", false)

func reparent_pass(scene):
	print("reparent pass ", reparent_nodes)
	for node in reparent_nodes:
		node[0].reparent(node[1], true)
		node[0].set_owner(scene)
		
		set_children_scene_root(scene,node[0])
		
func delete_pass():
	for node in delete_nodes:
		node.queue_free()

func set_children_scene_root(scene,node):
	for child in node.get_children():
		set_children_scene_root(scene,child)
		child.set_owner(scene)

func set_script_params(node, script_filepath):
	var script_file = FileAccess.open(script_filepath, FileAccess.READ)
	
	while not script_file.eof_reached():
		var line = script_file.get_line()
		var components = line.split('=')
		if len(components) > 1:
			var param_name = components[0]
			var expression = components[1]
			
			var e = Expression.new()
			e.parse(expression)
			node.set(param_name, e.execute())

func _material(node, metas, meta, meta_val):
	var surface_split = meta.split("_")
	if len(surface_split) > 0:
		var surface = surface_split[1]
		var material = load(meta_val)
		
		if "shader" in metas:
			var shader = load(node.get_meta("shader"))
			material.set_shader(shader)
		
		node.set_surface_override_material(int(surface), material)
					
func _multimesh(scene, node, metas, meta, meta_val):
	var mm_i = MultiMeshInstance3D.new()
	node.get_parent().add_child(mm_i)
	
	var scatter_size = Vector3(10,10,10)
	if "size_x" in metas:
		scatter_size.x = float(node.get_meta("size_x"))
		scatter_size.y = float(node.get_meta("size_y"))
		scatter_size.z = float(node.get_meta("size_z"))
	
	mm_i.set("scatter_size", scatter_size)
	
	mm_i.transform = node.transform
	
	var target : MeshInstance3D = scene.get_node(meta_val)
	mm_i.name = target.name + "_Multimesh"
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = target.mesh
	mm_i.multimesh = mm
	
	mm_i.set_owner(scene)
	
	##
	
	if "script" in metas:
		mm_i.set_script(load(node.get_meta("script")))
	
	##
	
	if "prop_file" in metas:
		set_script_params(mm_i, node.get_meta("prop_file"))
	
	# occlusion culling flickers... more investigation needed
	if "occlusion_culling" in metas:
		var occlusion = OccluderInstance3D.new()
		node.get_parent().add_child(occlusion)
		
		occlusion.name = "OccluderInstance3D"
		occlusion.transform = node.transform
		
		var box_occluder = BoxOccluder3D.new()
		box_occluder.size = scatter_size
		occlusion.occluder = box_occluder
		
		occlusion.set_owner(scene)
	##
	
	if "camera_node" in metas:
		var dyn_node = Node.new()
		node.get_parent().add_child(dyn_node)
		
		dyn_node.name = "DynamicInstancingNode"
		dyn_node.set_script(load(node.get_meta("dynamic_script")))
		
		dyn_node.set("target_path", node.get_meta("camera_node"))
		dyn_node.set("multimesh_path", "../" + mm_i.name)
		
		var plane_size = Vector2(scatter_size.x, scatter_size.z).length()
		
		dyn_node.set("distance_fade_start", plane_size)
		dyn_node.set("distance_fade_end", plane_size * 2)
		
		dyn_node.set_owner(scene)
	##
	
	# THIS DOES NOT WORK APPARENTLY
	if "group" in metas:
		mm_i.add_to_group(node.get_meta("group"), true)
	
	##
	
	target.hide()
	delete_nodes.append(node)

func _complex_col(scene, node, rigid_body, area_3d, simple, trimesh, meta_val, metas):
	print("complex col")
	
	var mesh_inst : MeshInstance3D = node
	if simple: mesh_inst.create_convex_collision()
	if trimesh: mesh_inst.create_trimesh_collision()
	mesh_inst.set_owner(scene)
	
	#if rigid_body or area_3d:
	var body = StaticBody3D.new()
	body.name = node.name + "_StaticBody3D"
	
	if rigid_body:
		body = RigidBody3D.new()
		body.name = node.name + "_RigidBody3D"
	
	if area_3d:
		body = Area3D.new()
		body.name = node.name + "_Area3D"
	
	if "name_override" in metas:
		if node.get_meta("name_override") != "":
			body.name = node.get_meta("name_override")
	
	#var col = node.get_children()[0].get_children()[0]
	#reparent_nodes.append([col, body])
	
	reparent_nodes.append([node, body])
	
	#delete_nodes.append(node.get_children()[0])
	
	var discard_mesh = "-d" in meta_val
	if discard_mesh: delete_nodes.append(node)
	
	node.get_parent().add_child(body)
	body.set_owner(scene)

func _simple_col(scene, node, rigid_body, area_3d, meta_val, metas):
	print("simple col",)
	var t = node.transform
	var body = StaticBody3D.new()
	body.name = "StaticBody3D_" + node.name
		
	
	if rigid_body:
		body = RigidBody3D.new()
		body.name = "RigidBody3D_" + node.name
	
	if area_3d:
		body = Area3D.new()
		body.name = "Area3D_" + node.name

	if "name_override" in metas:
		if node.get_meta("name_override") != "":
			body.name = node.get_meta("name_override")
	
	var col_only = "-c" in meta_val
	
	body.position = node.position
	
	
	var discard_mesh = "-d" in meta_val
	var nd : Node3D = node.duplicate()
	if not discard_mesh:
		# clear all children
		var children = []
		for child in nd.get_children():
			children.append(child)
		for child in children:
			nd.remove_child(child)
	
		nd.transform = Transform3D()
		nd.scale = node.scale
		nd.rotation = node.rotation
		
		body.add_child(nd)
	
	
	# only create a collision if not bodyonly
	var cs = CollisionShape3D.new()
	if "bodyonly" not in meta_val:
		cs.name = "CollisionShape3D_" + node.name
		
		if col_only:
			# here we capture position too because
			# these will be parented to a body
			# and we want to get the relative position
			cs.position = node.position
		
		cs.scale = node.scale
		cs.rotation = node.rotation
		
		if "box" in meta_val:
			if "size_x" in metas and "size_x" in metas \
			and "size_z" in metas:
				var bx = BoxShape3D.new()
				
				var size_x = float(node.get_meta("size_x"))
				var size_y = float(node.get_meta("size_y"))
				var size_z = float(node.get_meta("size_z"))
				
				bx.size = Vector3(size_x, size_y, size_z)
				
				cs.shape = bx
		
		if "cylinder" in meta_val:
			if "height" in metas and "radius" in metas:
				var cyl = CylinderShape3D.new()
				
				var height = float(node.get_meta("height"))
				var radius = float(node.get_meta("radius"))
				
				cyl.height = height
				cyl.radius = radius
				
				cs.shape = cyl
		
		if col_only:
			# collision gets added to the node parent mesh
			node.get_parent().add_child(cs)
			
		else:
			# otherwise add it to the body
			body.add_child(cs)
	
	if not col_only:
		scene.add_child(body)
		body.owner = scene
		if not discard_mesh: nd.owner = scene
		
	# Commented out because it causes a crash for some reason
	# I hope it isnt important!
	cs.owner = scene

	
	# check for any collisions children, reparent to body
	for child in node.get_children():
		if not col_only:
			if child is CollisionShape3D:
				reparent_nodes.append([child, body])
	print(reparent_nodes)
	
	
	delete_nodes.append(node)

func _collision(scene, node, metas, meta, meta_val):
	var mesh_inst : MeshInstance3D = node
	
	var rigid_body = false
	if "-r" in meta_val: rigid_body = true
	
	var area_3d = false
	if "-a" in meta_val: area_3d = true
	
	var simple = "simple" in meta_val
	var trimesh = "trimesh" in meta_val
	
	print("collision ", node, " simple:" , simple, " trimesh:", trimesh)
	
	if simple or trimesh:
		_complex_col(scene, node, rigid_body, area_3d, simple, trimesh, meta_val, metas)
	else:
		_simple_col(scene, node, rigid_body, area_3d, meta_val, metas)

func iterate_scene(scene, node):
	for child in node.get_children():
		iterate_scene(scene, child)
	
	# after this point, all children have been parsed (or don't exist)
	# we only ever parse mesh instance 3Ds from Blender (e.g. BLENDER OBJECTS)
	if node is MeshInstance3D:
		var mesh_inst : MeshInstance3D = node
		
		var metas = node.get_meta_list()
		for meta in metas:
			var meta_val = node.get_meta(meta)
			
			#if "material" in meta:
			#	_material(node, metas, meta, meta_val)
			
			if "material" in meta and meta_val == "alpha":
				for i in range(node.mesh.get_surface_count()):
					var mat = node.mesh.surface_get_material(i)
					if mat is BaseMaterial3D:
						mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				
				
			
			if "group" in meta:
				# TBD
				pass
			
			if "prop_file" in meta:
				# TBD
				pass
			
			if meta == "script":
				node.set_script(load(meta_val))
			
			if meta == "multimesh_target":
				_multimesh(scene, node, metas, meta, meta_val)
			
			# new collision logic as of v1.3 2024/02/01
			if meta == "collision":
				_collision(scene, node, metas, meta, meta_val)
			
			if meta == "state":
				if meta_val == "hide":
					node.hide()	
