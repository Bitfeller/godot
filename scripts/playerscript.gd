extends CharacterBody3D

# PLAYER VARIABLES
const IS_PLAYER = true

const MAX_HEALTH = 100
const HEAL_RATE = 0.01
var health = MAX_HEALTH - 50

const MAX_HUNGER = 100
const HUNGER_RATE = 0.005
var hunger = 0

const MAX_THIRST = 100
const THIRST_RATE = 0.005
var thirst = 0

const MAX_SANITY = 100
const SANITY_ROT = 0.001
var sanity = MAX_SANITY

const WALK_SPEED = 5.0
const SPRINT_SPEED = 5.0

const JUMP_VELOCITY = 4.5
const CAMERA_ROT_SPEED = 0.001

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# camera/player rot
var rot_x = 0
var rot_y = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(delta):
	if health < MAX_HEALTH and hunger <= 0.1 * MAX_HUNGER:
		health = min(MAX_HEALTH, health + HEAL_RATE)
	if hunger < MAX_HUNGER:
		hunger = min(MAX_HUNGER, hunger + HUNGER_RATE)
	if thirst < MAX_THIRST:
		thirst = min(MAX_THIRST, thirst + THIRST_RATE)
	if sanity > 0:
		sanity = max(0, sanity - SANITY_ROT)
	if Input.is_action_just_pressed("MouseLeft") and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# modify accumulated mouse rotation
		rot_x -= event.relative.x * CAMERA_ROT_SPEED
		rot_y -= event.relative.y * CAMERA_ROT_SPEED
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var speed = SPRINT_SPEED if Input.is_action_pressed("Sprint") else WALK_SPEED
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forwards", "Backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
