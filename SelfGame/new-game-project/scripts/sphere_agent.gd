
extends CharacterBody3D
class_name SphereAgent

@export var move_speed: float = 2.0
@export var preferred_distance: float = 4.0
@export var distance_tolerance: float = 0.5

var player: CharacterBody3D



func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D

	if player == null:
		print("ERROR: Player not found!")
	else:
		print("SUCCESS: Player found!")


func _physics_process(_delta: float) -> void:

	if player == null:
		return

	# Calculate the direction toward the player
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0

	var distance: float = to_player.length()

	if distance < 0.01:
		return

	var direction: Vector3 = to_player.normalized()

	# Too close: move away
	if distance < preferred_distance - distance_tolerance:
		velocity = -direction * move_speed

	# Too far: move closer
	elif distance > preferred_distance + distance_tolerance:
		velocity = direction * move_speed

	# Within preferred range: remain still
	else:
		velocity = Vector3.ZERO

	move_and_slide()
