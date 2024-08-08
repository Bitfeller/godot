extends Node


func _ready():
	var game = get_node('/root')
	var viewport = game.get_viewport()
	viewport.set_scaling_3d_scale(0.25)
	
