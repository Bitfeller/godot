extends Node

@onready var game = $".."
@onready var viewport = game.get_viewport()
@onready var root = get_node('/root').get_children()[0]

@onready var player = $"../Entities/Player"

var frameCount = 0

func set_3d_scaling(val : float):
	viewport.set_scaling_3d_scale(val)

func _ready():
	print(game, root, game.get_children(), root.get_children())
	print(player.health)
	# set_3d_scaling(0.3)

func _process(_delta):
	frameCount += 1
	if frameCount % 10 == 1:
		var barrelobj = load("res://scenes/barrel.tscn")
		var barrel = barrelobj.instantiate()
		$"../Models/barrels".add_child(barrel)
		barrel.transform.origin = Vector3(-0.789, 2, 3.414)
