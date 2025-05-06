class_name PlayerBody extends CharacterBody3D

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
	for slot in inventory.keys():
		inventory[slot] = null
	return true
func clear_hotbar() -> bool:
	for slot in hotbar.keys():
		hotbar[slot] = null
	return true
func clear_offhand() -> bool:
	offhand = null
	return true

func _add_item_to_dict(dict, item, num, limit, slotnum = null) -> bool:
	if Resources.Items[item]:
		# slotnum
		if slotnum:
			if dict[slotnum] and dict[slotnum].name == item:
				dict[slotnum].num += num
			elif dict[slotnum] == null:
				dict[slotnum] = {
					"name": item,
					"num": num
				}
			# overflow
			var overflow = dict[slotnum].num - Resources.Items[item].max_stack
			if overflow > 0:
				return add_to_inv_sys(item, overflow)
			return true
		var idx
		var firstNull
		for slot in dict.keys():
			if dict[slot] == null:
				firstNull = slot
			if dict[slot].name == item:
				idx = slot
				dict[slot].num += num
				break
		if not idx:
			if not firstNull:
				return false # full
			idx = firstNull
			dict[firstNull] = {
				"name": item,
				"num": num
			}
		# overflow
		var overflow = dict[idx].num - Resources.Items[item].max_stack
		if overflow > 0:
			return add_to_inv_sys(item, overflow)
	else:
		return false
	return true
func add_to_inventory(item, num, slot = null) -> bool:
	return _add_item_to_dict(inventory, item, num, INVENTORY_MAX, slot)
func add_to_hotbar(item, num, slot = null) -> bool:
	return _add_item_to_dict(hotbar, item, num, HOTBAR_MAX, slot)
func add_to_offhand(item, num) -> bool:
	if Resources.Items[item]:
		if offhand == null:
			offhand = {
				"name": item,
				"num": num
			}
		elif offhand.item == item:
			offhand.num += num
		else:
			return false
		# overflow
		var overflow = offhand.num - Resources.Items[item].max_stack
		if overflow > 0:
			return add_to_inv_sys(item, overflow)
	else:
		return false
	return true

func _remove_item_from_dict(dict, item, num, slotnum = null) -> bool:
	# slotnum handle
	if slotnum:
		if dict[slotnum] and dict[slotnum].name == item:
			if num == "all":
				dict[slotnum] = null
			else:
				dict[slotnum].num -= num
				if dict[slotnum].num <= 0:
					dict[slotnum] = null
			return true
		else:
			return false
	for slot in dict:
		if dict[slot].name == item:
			if num == "all":
				dict[slot] = null
			else:
				dict[slot].num -= num
				if dict[slot].num <= 0:
					dict[slot] = null
			return true
	return false
func remove_from_inventory(item, num, slot = null) -> bool:
	return _remove_item_from_dict(inventory, item, num, slot)
func remove_from_hotbar(item, num, slot = null) -> bool:
	return _remove_item_from_dict(hotbar, item, num, slot)
func remove_from_offhand(num) -> bool:
	if offhand == null:
		return false
	offhand.num -= num
	if offhand.num <= 0:
		offhand = null
	return true

func add_to_inv_sys(item, num) -> bool:
	var success = add_to_hotbar(item, num)
	if not success:
		success = add_to_inventory(item, num)
	if not success:
		return false
	return true

func find_item(item : String) -> Array:
	if offhand.name == item:
		return ["offhand", 0, offhand]
	for slot in hotbar:
		if hotbar[slot].name == item:
			return ["hotbar", slot, hotbar[slot]]
	for slot in inventory:
		if inventory[slot].name == item:
			return ["inventory", slot, inventory[slot]]
	return [false]
func selective_find_item(location : Dictionary, item : String) -> Array:
	for slot in location:
		if location[slot].name == item:
			return [slot, location[slot]]
	return [false]

# default functions
func _ready():
	# define slots into hotbar and inventory
	for i in range(HOTBAR_MAX):
		hotbar[str(i)] = {}
	for i in range(INVENTORY_MAX):
		inventory[str(i)] = {}
	
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
