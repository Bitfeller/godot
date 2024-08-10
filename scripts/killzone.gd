extends Area3D

func _process(delta):
	var a = $"../RigidBody3D"
	print(a.get_storage())

func _on_body_entered(body):
	if body.get_parent().name == "barrels":
		body.queue_free()
	if body is PlayerBody:
		body.queue_free()
		get_tree().reload_current_scene()
