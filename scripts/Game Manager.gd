extends Node

@onready var game = $".."
@onready var viewport = game.get_viewport()
@onready var root = get_node('/root').get_children()[0]

@onready var player = $"../Entities/Player"

func set_3d_scaling(val : float):
	viewport.set_scaling_3d_scale(val)

func _ready():
	print(game, root, game.get_children(), root.get_children())
	print(player.health)
	# set_3d_scaling(0.3)
