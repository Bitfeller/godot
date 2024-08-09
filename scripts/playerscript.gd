extends CharacterBody3D

# GLOBAL VARIABLES
@onready var resources = $"../../Resources";

# PLAYER VARIABLES
const IS_PLAYER = true

const MAX_HEALTH = 100
const HEAL_RATE = 0.01
var health = MAX_HEALTH

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
const SPRINT_SPEED = 10.0

const JUMP_VELOCITY = 4.5
const CAMERA_ROT_SPEED = 0.001
const CAMERA_MAX_Y_DEG = 70

const HOTBAR_MAX = 5
const INVENTORY_MAX = 25
var hotbar = {}
var inventory = {}
var offhand

# camera/player rot
var camrot_x = 0
var camrot_y = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# inventory functions
func get_inventory() -> Dictionary:
	return inventory
func get_hotbar() -> Dictionary:
	return hotbar
func get_offhand():
	return offhand
func clear_inventory() -> bool:
	inventory = {}
	return true
func clear_hotbar() -> bool:
	hotbar = {}
	return true
func clear_offhand() -> bool:
	offhand = null
	return true
func _add_item_to_dict(dict, item, amount, limit) -> bool:
	if resources.Items[item]:
		if dict[item]:
			dict[item].amount += amount
		else:
			if dict.size() >= limit:
				return false
			dict[item] = {
				"amount": amount
			}
	else:
		return false
	return true
func add_to_inventory(item, amount) -> bool:
	return _add_item_to_dict(inventory, item, amount, INVENTORY_MAX)
func add_to_hotbar(item, amount) -> bool:
	return _add_item_to_dict(hotbar, item, amount, HOTBAR_MAX)
func add_to_offhand(item, amount) -> bool:
	if resources.Items[item]:
		if offhand == null:
			offhand = {
				"item": item,
				"amount": amount
			}
		elif offhand.item == item:
			offhand.amount += amount
		else:
			return false
	else:
		return false
	return true
func _remove_item_from_dict(dict, item, amount) -> bool:
	if dict[item]:
		if amount == "all":
			dict.erase(item)
		else:
			dict[item].amount -= amount;
			if dict[item].amount <= 0:
				dict.erase(item)
	else:
		return false
	return true
func remove_from_inventory(item, amount) -> bool:
	return _remove_item_from_dict(inventory, item, amount)
func remove_from_hotbar(item, amount) -> bool:
	return _remove_item_from_dict(hotbar, item, amount)
func remove_from_offhand(amount) -> bool:
	offhand.amount -= amount;
	if offhand.amount <= 0:
		offhand = null
	return true
func add_to_inv_sys(item, amount) -> bool:
	if hotbar.size() < HOTBAR_MAX:
		add_to_hotbar(item, amount)
	elif inventory.size() < INVENTORY_MAX:
		add_to_inventory(item, amount)
	else:
		return false
	return true
# CHEST 1 => 1 apple
# Chestscript => remove 1 apple
# Playerscript => hotbar full? yes => add_to_inventory(1 apple)


# default functions
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(_delta):
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
		camrot_x -= event.relative.x * CAMERA_ROT_SPEED
		camrot_y -= event.relative.y * CAMERA_ROT_SPEED
		transform.basis = Basis() # reset rotation
		$Camera3D.transform.basis = Basis() # reset rotation
		rotate_y(camrot_x)
		$Camera3D.rotate_x(camrot_y)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(CAMERA_MAX_Y_DEG), deg_to_rad(CAMERA_MAX_Y_DEG))

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
