
extends CharacterBody3D

# Movement settings
@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002

var gravity: float = 9.8

# Node references
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var inventory_label: Label = $CanvasLayer/InventoryLabel

# Cube inventory
const MAX_CUBES: int = 3

var inventory: Array[IdentityCube] = []
var selected_slot: int = 0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_inventory_display()


func _unhandled_input(event: InputEvent) -> void:

	# Escape releases the cursor
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	# Recapture cursor when clicking the game
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseButton and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	# Mouse look
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		head.rotate_x(-event.relative.y * mouse_sensitivity)

		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-89),
			deg_to_rad(89)
		)

	# Right click: collect a cube
	if event.is_action_pressed("pickup"):
		pickup_cube()

	# Shift: cycle inventory
	if event.is_action_pressed("cycle_inventory"):
		cycle_inventory()

	# Left click: use selected cube
	if event.is_action_pressed("use_cube"):
		use_selected_cube()


func _physics_process(delta: float) -> void:

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Movement
	var input_dir: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
        "move_backward"
	)

	var direction: Vector3 = (
		transform.basis * Vector3(
			input_dir.x,
			0,
			input_dir.y
		)
	).normalized()

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	move_and_slide()


func pickup_cube() -> void:

	# Maximum inventory capacity
	if inventory.size() >= MAX_CUBES:
		print("Inventory full")
		return

	raycast.force_raycast_update()

	if not raycast.is_colliding():
		return

	var object = raycast.get_collider()

	if object is IdentityCube:

		var cube: IdentityCube = object

		if inventory.has(cube):
			return

		# Stop the cube's movement
		cube.linear_velocity = Vector3.ZERO
		cube.angular_velocity = Vector3.ZERO
		cube.freeze = true

		# Remove it temporarily from the world
		cube.collision_layer = 0
		cube.collision_mask = 0
		cube.visible = false

		# Store the actual cube instance
		inventory.append(cube)

		# Select the newly collected cube
		selected_slot = inventory.size() - 1

		print("Picked up Cube ", cube.cube_id)

		update_inventory_display()


func cycle_inventory() -> void:

	if inventory.is_empty():
		return

	selected_slot = (
		selected_slot + 1
	) % inventory.size()

	update_inventory_display()


func use_selected_cube() -> void:

	if inventory.is_empty():
		return

	var cube: IdentityCube = inventory[selected_slot]

	# Determine the direction the player faces
	var forward: Vector3 = -camera.global_transform.basis.z

	# Check whether an interactable target is ahead
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var target = raycast.get_collider()

		if target.has_method("use_cube"):
			var succeeded: bool = target.use_cube(cube)

			if succeeded:
				update_inventory_display()
				return

	# Otherwise deploy the cube into the world
	cube.global_position = (
		camera.global_position + forward * 1.6
	)

	cube.visible = true
	cube.collision_layer = 1
	cube.collision_mask = 1
	cube.freeze = false

	# Give it a small forward impulse
	cube.apply_central_impulse(forward * 2.5)

	# Remove it from inventory
	inventory.remove_at(selected_slot)

	if inventory.is_empty():
		selected_slot = 0
	else:
		selected_slot = selected_slot % inventory.size()

	update_inventory_display()


func update_inventory_display() -> void:

	var display_text: String = "INVENTORY\n"

	for i in range(MAX_CUBES):

		var slot_text: String = "EMPTY"

		if i < inventory.size():
			slot_text = "CUBE " + str(inventory[i].cube_id)

		if i == selected_slot:
			display_text += "[ " + slot_text + " ] "
		else:
			display_text += "  " + slot_text + "   "

	inventory_label.text = display_text
