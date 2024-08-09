extends RigidBody3D

@export var roll_impulse: Vector3 = Vector3(0, 0, 15)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_body_entered(body):
	if body is CharacterBody3D and body.IS_PLAYER == true:
		print("worked!")
		linear_velocity = roll_impulse
	
