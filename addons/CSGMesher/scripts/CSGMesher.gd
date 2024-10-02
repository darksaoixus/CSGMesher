class_name CSGMesher
extends RefCounted

static func add_node_to_tree(parent_node: Node, csg: CSGShape3D) -> Node3D:
	if not csg:
		push_warning("csg is null!")
		return
	
	var node_to_add := make_node_to_add(csg)
	for child in parent_node.get_children():
		parent_node.remove_child(child)
		child.free()
	parent_node.add_child(node_to_add)
	node_to_add.owner = parent_node.owner
	node_to_add.request_ready()
	node_to_add.global_transform = parent_node.global_transform
	
	for child in node_to_add.get_children():
		child.owner = node_to_add.owner
	
	node_to_add.name = csg.name
	
	csg.queue_free()
	return node_to_add


static func make_node_to_add(csg: CSGShape3D) -> Node3D:
	var csg_mesh: Mesh = csg.get_meshes()[1]
	
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = csg_mesh
	mesh_instance.name = csg.name + "_mesh"
	
	if csg.use_collision:
		var static_body := StaticBody3D.new()
		var collision   := CollisionShape3D.new()
		
		collision.shape = csg_mesh.create_convex_shape(false)
		
		static_body.add_child(mesh_instance)
		static_body.add_child(collision)
		
		collision.name = csg.name + "_col"
		
		return static_body
	
	var node3d := Node3D.new()
	node3d.add_child(mesh_instance)
	
	return node3d
