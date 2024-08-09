extends Area3D

func _on_body_entered(body):
	if body.get_parent().name == "barrels":
		body.queue_free()
	if body is CharacterBody3D and body.IS_PLAYER:
		body.queue_free()
		get_tree().reload_current_scene()
