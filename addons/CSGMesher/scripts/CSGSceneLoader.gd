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
		
		CSGMesher.add_node_to_tree(self, csg)
