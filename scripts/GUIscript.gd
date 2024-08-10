extends Panel

@onready var Player = Resources.player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$SanityBar.value = Player.sanity
	$ThirstBar.value = Player.thirst
	$HungerBar.value = Player.hunger
	$HealthBar.value = Player.health

