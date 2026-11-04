
extends CharacterBody3D

# Player movement settings
@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002

# Gravity
var gravity: float = 9.8

# Reference to the player's head
@onready var head: Node3D = $Head


func _ready() -> void:
	# Hide and capture the cursor
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Rotate the camera with the mouse
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * mouse_sensitivity)
			head.rotate_x(-event.relative.y * mouse_sensitivity)

			# Prevent looking too far up or down
			head.rotation.x = clamp(
				head.rotation.x,
				deg_to_rad(-89),
				deg_to_rad(89)
			)

	# Escape releases the mouse
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Click to recapture the mouse
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Read WASD input
	var input_dir: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
        "move_backward"
	)

	# Convert input to 3D movement direction
	var direction: Vector3 = (
		transform.basis * Vector3(
			input_dir.x,
			0,
			input_dir.y
		)
	).normalized()

	# Apply horizontal movement
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	# Move the character
	move_and_slide()
	
	
