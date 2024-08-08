extends Node

@onready var game = $".."



func _ready():
	var viewport = game.get_viewport()
	viewport.set_scaling_3d_scale(0.3)
	
