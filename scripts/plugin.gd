@tool
extends EditorPlugin


func _enter_tree() -> void:
    print("CSGMesher enabled")


func _exit_tree() -> void:
    print("CSGMesher disabled")
