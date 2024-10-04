@tool
class_name CSGSceneLoader
extends Node3D

var csg: CSGShape3D

@export var csg_scene_file: PackedScene:
	set(value):
		csg_scene_file = value
		if not self.is_node_ready():
			await self.ready
		load_scene_callback()

@export var load_scene: bool = false:
	set(value):
		load_scene = value
		if load_scene:
			if not self.is_node_ready():
				await self.ready
			load_scene_callback()
			load_scene = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		load_scene_callback()


func load_scene_callback() -> void:
	
	if csg_scene_file:
		var scene_instance: Node = csg_scene_file.instantiate()
		if not scene_instance is CSGShape3D:
			push_warning("%s is not CSGShape3D! (Type: %s)" % [scene_instance.name, scene_instance.get_class()])
			return
		
		csg = scene_instance as CSGShape3D
		csg._update_shape()
		
		add_node_to_tree(csg)


func add_node_to_tree(csg: CSGShape3D) -> Node3D:
	if not csg:
		push_warning("csg is null!")
		return
	
	var node_to_add := make_node_to_add(csg)
	for child in self.get_children():
		self.remove_child(child)
		child.free()
	self.add_child(node_to_add)
	node_to_add.owner = self.owner
	node_to_add.request_ready()
	node_to_add.global_transform = self.global_transform
	
	for child in node_to_add.get_children():
		child.owner = node_to_add.owner
	
	node_to_add.name = csg.name
	
	csg.queue_free()
	return node_to_add


func make_node_to_add(csg: CSGShape3D) -> Node3D:
	var csg_mesh: Mesh = csg.get_meshes()[1]
	
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = csg_mesh
	mesh_instance.name = csg.name + "_mesh"
	
	if csg.use_collision:
		var static_body := StaticBody3D.new()
		var collision   := CollisionShape3D.new()
		
		collision.shape = csg_mesh.create_trimesh_shape()
		
		static_body.add_child(mesh_instance)
		static_body.add_child(collision)
		
		collision.name = csg.name + "_col"
		
		return static_body
	
	var node3d := Node3D.new()
	node3d.add_child(mesh_instance)
	
	return node3d
